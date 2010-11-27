class MaterialCostLine < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :material_set, :class_name => "MaterialCost"
  
  validates_presence_of :name, :quantity, :material_set
end
