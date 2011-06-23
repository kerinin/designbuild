class Contract < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail :ignore => [:position, :created_at, :updated_at]
  #has_invoices
  
  belongs_to :project, :inverse_of => :contracts
  belongs_to :component, :inverse_of => :contracts
  belongs_to :active_bid, :class_name => "Bid", :foreign_key => :bid_id
  
  has_many :tasks, :order => :name
  has_many :costs, :class_name => "ContractCost", :order => "date DESC", :dependent => :destroy
  has_many :bids, :order => :contractor, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
  has_many :applied_markings, :class_name => 'Marking'
  
  has_many :estimated_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :estimated_cost}, :dependent => :destroy
  has_many :cost_to_date_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :cost_to_date}, :dependent => :destroy
    
  acts_as_list :scope => :project
  
  validates_presence_of :name, :project, :component

  before_validation :check_project
  before_save :update_markings, :if => proc {|i| i.component_id_changed? }, :unless => proc {|i| i.markings.empty? }
  
  #after_save :create_estimated_cost_points, :if => proc {|i| i.estimated_cost_changed? && ( !i.new_record? || ( !i.estimated_cost.nil? && i.estimated_cost > 0 ) )}
  #after_save :create_cost_to_date_points, :if => proc {|i| i.cost_changed? && ( !i.new_record? || ( !i.cost.nil? && i.cost > 0 ) )}
    
  default_scope :order => :position
  
  scope :without_component, lambda { where( {:component_id => nil} ) }
  
  def update_markings
    self.markings.update_all(:component_id => self.component_id)
  end
  
  def estimated_cost
    self.estimated_raw_cost + self.markings.sum(:estimated_cost_markup_amount)
  end

  def cost
    self.contract_costs.joins(:markings).sum("contract_costs.raw_cost + markings.cost_markup_amount")
  end
    
  def markups
    self.component.markups
  end
  
  def percent_invoiced
    multiply_or_nil( 100, divide_or_nil( self.cost, self.estimated_cost ) )
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
end
