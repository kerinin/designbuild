class LaborCostLine < ActiveRecord::Base  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :project
  belongs_to :labor_set, :class_name => "LaborCost", :inverse_of => :line_items
  belongs_to :laborer, :inverse_of => :labor_cost_lines
  
  has_one :task, :through => :labor_set
  
  validates_presence_of :labor_set, :hours
  
  validates_numericality_of :hours
  
  before_save :set_costs
  
  before_save :set_project
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  scope :by_project, lambda {|project| where(:project_id => project.id )  } 
  
  def markups
    self.labor_set.markups
  end
  
  def set_project
    self.project = self.labor_set.project
  end
  
  def set_costs
    unless self.laborer.blank?
      self.raw_cost = self.hours * self.laborer.bill_rate unless ( self.hours.nil? || self.laborer.blank? || self.laborer.bill_rate.nil? || self.laborer.destroyed? )
      self.laborer_pay = self.hours * self.laborer.pay_rate unless ( self.hours.nil? || self.laborer.blank? || self.laborer.pay_rate.nil? || self.laborer.destroyed? )
    
      self.cost = self.raw_cost + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_cost) }
    end
  end

  def cascade_cache_values
    self.labor_set.reload.save!
  end
end
