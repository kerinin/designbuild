class MaterialCostLine < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :material_set, :class_name => "MaterialCost", :inverse_of => :line_items
  
  validates_presence_of :name, :material_set
end
