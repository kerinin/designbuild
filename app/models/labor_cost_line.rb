class LaborCostLine < ActiveRecord::Base
  belongs_to :labor_set, :class_name => "LaborCost"
  
  validates_presence_of :labor_set
end
