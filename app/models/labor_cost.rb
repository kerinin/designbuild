class LaborCost < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail
  
  belongs_to :task
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy
  
  validates_presence_of :task, :percent_complete
  validates_numericality_of :percent_complete
  
  after_save :deactivate_task_if_done
  
  # cost
  
  # raw_cost
  
  private
  
  def cache_cost
    self.raw_cost = self.line_items.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.cost = multiply_or_nil self.raw_cost, (1+(self.task.total_markup/100))
  end
  
  def deactivate_task_if_done
    self.task.active = false if self.percent_complete >= 100
    self.task.save!
  end
end
