class MaterialCost < ActiveRecord::Base
  belongs_to :task
  belongs_to :supplier
  
  has_many :line_items, :class_name => "MaterialCostLine", :foreign_key => :material_set_id, :order => :name
  
  validates_presence_of :task, :supplier, :date
end
