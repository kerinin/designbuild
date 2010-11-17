class MaterialCostLine < ActiveRecord::Base
  belongs_to :material_set, :class_name => "MaterialCost"
  
  validates_presence_of :name, :quantity, :material_set
  
  validates_numericality_of :quantity
end
