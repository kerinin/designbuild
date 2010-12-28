class Contract < ActiveRecord::Base
  include AddOrNil
  include MarksUp
  
  has_paper_trail :ignore => [:position, :created_at, :updated_at]
  has_invoices
  
  belongs_to :project, :inverse_of => :contracts
  belongs_to :component, :inverse_of => :contracts
  belongs_to :active_bid, :class_name => "Bid", :foreign_key => :bid_id
  
  has_many :tasks, :order => :name
  has_many :costs, :class_name => "ContractCost", :order => "date DESC", :dependent => :destroy
  has_many :bids, :order => :contractor, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => Proc.new{|c,m| c.save}, :after_remove => Proc.new{|c,m| c.save}
    
  acts_as_list :scope => :project
  
  validates_presence_of :name, :project, :component

  after_create :add_project_markups, :unless => :component_id
  after_create :add_component_markups, :if => :component_id
  
  before_validation :check_project
  before_save :cache_values
  
  after_save :cascade_cache_values  
  after_destroy :cascade_cache_values
  
  default_scope :order => :position
  
  scope :without_component, lambda { where( {:component_id => nil} ) }
  
  def percent_invoiced
    multiply_or_nil( 100, divide_or_nil( self.raw_invoiced, self.raw_cost ) )
  end
  
  marks_up :raw_cost_before
  def raw_cost_before(date)
    self.costs.where('date <= ?', date).sum(:raw_cost)
  end
  
  def cache_values
    [self.bids, self.costs, self.markups].each {|r| r.reload}
    
    self.cache_estimated_cost
    self.cache_cost
    self.cache_total_markup
  end
    
  def cascade_cache_values
    self.component.save! unless self.component.blank?
    self.project.save! unless self.project.blank?
    
    Component.find(self.component_id_was).save! if self.component_id_changed? && !self.component_id_was.nil?
    Project.find(self.project_id_was).save! if self.project_id_changed? && !self.project_id_was.nil?
  end
  
  def percent_complete
    self.percent_complete_float * 100
  end
  
  def percent_complete_float
    divide_or_nil( self.cost, self.estimated_cost) || 0
  end

  
  protected  
  
  def check_project
    self.project ||= self.component.project if !self.component.nil? && !self.component.project.nil?
  end
  
  def cache_estimated_cost
    self.estimated_raw_cost = ( (self.active_bid.blank? || self.active_bid.destroyed?) ? nil : self.active_bid.raw_cost )
    self.estimated_cost = mark_up :estimated_raw_cost
  end
  
  def cache_cost
    self.raw_cost = self.costs.sum(:raw_cost)
    self.cost = mark_up :raw_cost
  end
  
  def cache_total_markup
    self.total_markup = self.markups.sum(:percent)
  end
  
  
  def add_project_markups
    self.project.markups.all.each {|m| self.markups << m unless self.markups.include? m }
  end
  
  def add_component_markups
    self.component.markups.all.each {|m| self.markups << m unless self.markups.include? m }
  end
end
