class LaborCost < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail
  
  belongs_to :task
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy, :after_save => :cache_values, :after_remove => :cache_values
  
  validates_presence_of :task, :percent_complete
  validates_numericality_of :percent_complete
  
  after_save :deactivate_task_if_done, :cache_values
  after_destroy :cache_values
  
  def cost
    multiply_or_nil self.raw_cost, (1+(self.task.total_markup/100))
  end
  
  # raw_cost
  
  private
  
  def cache_values
    self.cache_raw_cost
    
    self.task.cache_values
  end
  
  def cache_raw_cost
    self.raw_cost = self.line_items.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  end
  
  def deactivate_task_if_done
    self.task.active = false if self.percent_complete >= 100
    self.task.save!
  end
end
