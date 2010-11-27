class LaborCostLine < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :labor_set, :class_name => "LaborCost"
  belongs_to :laborer
  
  validates_presence_of :labor_set, :laborer, :hours
  
  validates_numericality_of :hours
  
  def cost
    multiply_or_nil self.raw_cost, (1+(self.labor_set.task.total_markup/100))
  end
  
  def raw_cost
    self.hours * self.laborer.bill_rate unless self.laborer.blank?
  end
end
