class LaborCostLine < ActiveRecord::Base
  belongs_to :labor_set, :class_name => :labor_cost
end
