class LaborCost < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :task
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy
  
  validates_presence_of :task, :percent_complete
  validates_numericality_of :percent_complete
  
  
  def cost
    self.line_items.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end
end
