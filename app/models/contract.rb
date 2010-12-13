class Contract < ActiveRecord::Base
  include AddOrNil
  include MarksUp
  
  has_paper_trail :ignore => [:position]
  has_invoices
  
  belongs_to :project
  belongs_to :component
  belongs_to :active_bid, :class_name => "Bid", :foreign_key => :bid_id
  
  has_many :tasks, :order => :name
  has_many :costs, :class_name => "ContractCost", :order => "date DESC", :dependent => :destroy
  has_many :bids, :order => :contractor, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => Proc.new{|c,m| c.save}, :after_remove => Proc.new{|c,m| c.save}
    
  acts_as_list :scope => :project
  
  validates_presence_of :name, :project

  after_create :add_project_markups, :unless => :component_id
  after_create :add_component_markups, :if => :component_id
  
  before_validation :check_project
  before_save :cache_values
  
  after_save :cascade_cache_values  
  after_destroy :cascade_cache_values
  
  default_scope :order => :position
  
  scope :without_component, lambda { where( 'contract_id IS NOT NULL' ) }
  
  def percent_invoiced
    multiply_or_nil( 100, divide_or_nil( self.raw_invoiced, self.raw_cost ) )
  end

  
  # estimated_cost
  marks_up :estimated_raw_cost
  
  # estimated_raw_cost
  
  # cost
  marks_up :raw_cost
  
  # raw_cost
  
  def cache_values
    [self.bids, self.costs, self.markups].each {|r| r.reload}
    
    self.cache_estimated_raw_cost
    self.cache_raw_cost
    self.cache_total_markup
  end
    
  def cascade_cache_values
    self.component.reload.save! unless self.component.blank?
    self.project.reload.save! unless self.project.blank?
    
    Component.find(self.component_id_was).save! if self.component_id_changed? && !self.component_id_was.nil?
    Project.find(self.project_id_was).save! if self.project_id_changed? && !self.project_id_was.nil?
  end
  
  
  # Invoicing
  [:labor_cost, :material_cost].each do |sym|
    self.send(:define_method, sym) do
      divide_or_nil self.cost, 2
    end
  end
  
  def percent_complete
    self.percent_complete_float * 100
  end
  
  def percent_complete_float
    divide_or_nil( self.invoiced, self.cost) || 0
  end

  
  protected  
  
  def check_project
    self.project ||= self.component.project if !self.component.nil? && !self.component.project.nil?
  end
  
  def cache_estimated_raw_cost
    self.estimated_raw_cost = ( (self.active_bid.blank? || self.active_bid.destroyed?) ? nil : self.active_bid.raw_cost )
  end
  
  def cache_raw_cost
    self.raw_cost = self.costs.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  end
  
  def cache_total_markup
    self.total_markup = self.markups.all.inject(0) {|memo,obj| memo + obj.percent }
  end
  
  
  def add_project_markups
    self.project.markups.all.each {|m| self.markups << m unless self.markups.include? m }
  end
  
  def add_component_markups
    self.component.markups.all.each {|m| self.markups << m unless self.markups.include? m }
  end
end
