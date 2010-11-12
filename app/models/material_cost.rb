class MaterialCost < ActiveRecord::Base
  belongs_to :task
  
  has_many :line_items, :class_name => "MaterialCostLine", :foreign_key => :material_set_id
  
  validates_presence_of :task
end
