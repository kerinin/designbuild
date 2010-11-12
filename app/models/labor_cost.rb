class LaborCost < ActiveRecord::Base
  belongs_to :task
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id
  
  validates_presence_of :task
end
