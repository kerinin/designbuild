class MaterialCost < ActiveRecord::Base
  belongs_to :task
  belongs_to :supplier
  
  has_many :line_items, :class_name => "MaterialCostLine", :foreign_key => :material_set_id, :order => :name
  
  validates_presence_of :task, :supplier
  
  accepts_nested_attributes_for :line_items, :reject_if => :all_blank
end
