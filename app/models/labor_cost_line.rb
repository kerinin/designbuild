class LaborCostLine < ActiveRecord::Base
  belongs_to :labor_set, :class_name => "LaborCost"
  belongs_to :laborer
  
  validates_presence_of :labor_set, :laborer, :hours
  
  def cost
    self.hours * self.laborer.pay_rate
  end
end
