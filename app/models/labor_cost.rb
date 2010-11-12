class LaborCost < ActiveRecord::Base
  belongs_to :task
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id
  
  validates_presence_of :task
  
  def cost
    self.line_items.empty? ? nil : self.line_items.inject(nil) {|memo, obj| cost = obj.cost; memo.nil? ? obj.cost : memo + (cost.nil? ? 0 : cost)}
  end
end
