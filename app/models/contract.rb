class Contract < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail :ignore => [:position, :created_at, :updated_at]
  has_invoices
  
  belongs_to :project, :inverse_of => :contracts
  belongs_to :component, :inverse_of => :contracts
  belongs_to :active_bid, :class_name => "Bid", :foreign_key => :bid_id
  
  has_many :tasks, :order => :name
  has_many :costs, :class_name => "ContractCost", :order => "date DESC", :dependent => :destroy
  has_many :bids, :order => :contractor, :dependent => :destroy

  has_many :estimated_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :estimated_cost}
  has_many :cost_to_date_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :cost_to_date}
    
  acts_as_list :scope => :project
  
  validates_presence_of :name, :project, :component

  before_validation :check_project
  before_save :cache_values
  
  after_save :cascade_cache_values  
  after_destroy :cascade_cache_values
  
  after_save :create_estimated_cost_points, :if => proc {|i| i.estimated_cost_changed? && ( !i.new_record? || ( !i.estimated_cost.nil? && i.estimated_cost > 0 ) )}
  #after_save :create_cost_to_date_points, :if => proc {|i| i.cost_changed? && ( !i.new_record? || ( !i.cost.nil? && i.cost > 0 ) )}
    
  default_scope :order => :position
  
  scope :without_component, lambda { where( {:component_id => nil} ) }
  
  def markups
    self.component.markups
  end
  
  def percent_invoiced
    multiply_or_nil( 100, divide_or_nil( self.invoiced, self.estimated_cost ) )
  end
  
  # Hack for cost_to_date points
  def labor_cost_before(date)
    self.cost_before(date)
  end
  
  def material_cost_before(date)
    0
  end
  
  def cost_before(date)
    self.raw_cost_before(date) + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_cost_before, date) }
  end
  
  def raw_cost_before(date)
    self.costs.where('date <= ?', date).sum(:raw_cost)
  end
  
  def cache_values
    [self.bids, self.costs, self.markups].each {|r| r.reload}
    
    self.cache_estimated_cost
    self.cache_cost
  end
    
  def cascade_cache_values
    self.component.reload.save!
    self.project.reload.save!
    
    Component.find(self.component_id_was).save! if self.component_id_changed? && !self.component_id_was.nil? && Component.exists?(:id => self.component_id_was)
    Project.find(self.project_id_was).save! if self.project_id_changed? && !self.project_id_was.nil? && Project.exists?(:id => self.project_id_was)
  end
  
  def percent_complete
    self.percent_complete_float * 100
  end
  
  def percent_complete_float
    divide_or_nil( self.cost, self.estimated_cost) || 0
  end

  def create_estimated_cost_points
    p = self.estimated_cost_points.find_or_initialize_by_date(:date => Date::today)
    if p.label.nil?
      p.series = :estimated_cost
      p.value = self.estimated_cost || 0
      p.save!
    end
  end
  
  def create_cost_to_date_points(date)
    p = self.cost_to_date_points.find_or_create_by_date(date)
    if p.label.nil?
      p.series = :cost_to_date
      p.value = self.cost_before(date)
      p.save!
    end
  end
    
  protected  
  
  def check_project
    self.project ||= self.component.project if !self.component.nil? && !self.component.project.nil?
  end
  
  def cache_estimated_cost
    self.estimated_raw_cost = ( (self.active_bid.blank? || self.active_bid.destroyed?) ? 0 : self.active_bid.raw_cost )
    self.estimated_cost = self.estimated_raw_cost + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :estimated_raw_cost) }
  end
  
  def cache_cost
    self.raw_cost = self.costs.sum(:raw_cost)
    self.cost = self.raw_cost + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_cost) }
  end
end
