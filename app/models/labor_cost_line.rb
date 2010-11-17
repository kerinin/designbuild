class LaborCostLine < ActiveRecord::Base
  belongs_to :labor_set, :class_name => "LaborCost"
  belongs_to :laborer
  
  validates_presence_of :labor_set, :laborer, :hours
  
  validates_numericality_of :hours
  
  def cost
    self.hours * self.laborer.bill_rate
  end
end
