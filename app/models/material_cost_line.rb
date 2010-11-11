class MaterialCostLine < ActiveRecord::Base
  belongs_to :material_set, :class_name => :material_cost
end
