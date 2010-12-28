class LaborCostLine < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :project
  belongs_to :labor_set, :class_name => "LaborCost", :inverse_of => :line_items
  belongs_to :laborer, :inverse_of => :labor_cost_lines
  
  has_one :task, :through => :labor_set
  
  validates_presence_of :labor_set, :laborer, :hours
  
  validates_numericality_of :hours
  
  before_validation :set_costs
  
  before_save :set_project
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  scope :by_project, lambda {|project| where(:project_id => project.id )  } 
  
  def total_markup
    self.labor_set.total_markup unless self.labor_set.blank?
  end
  
  def set_project
    self.project = self.labor_set.project
  end
  
  def set_costs
    self.raw_cost = self.hours * self.laborer.bill_rate unless ( self.hours.nil? || self.laborer.blank? || self.laborer.bill_rate.nil? || self.laborer.destroyed? )
    self.laborer_pay = self.hours * self.laborer.pay_rate unless ( self.hours.nil? || self.laborer.blank? || self.laborer.pay_rate.nil? || self.laborer.destroyed? )
    
    self.cost = mark_up :raw_cost
  end

  def cascade_cache_values
    self.labor_set.save!
  end
end
