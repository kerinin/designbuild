class LaborCost < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail
  
  belongs_to :task
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy
  
  validates_presence_of :task, :percent_complete
  validates_numericality_of :percent_complete
  
  after_save :deactivate_task_if_done
  
  def cost
    self.line_items.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end
  
  private
  
  def deactivate_task_if_done
    self.task.active = false if self.percent_complete >= 100
    self.task.save!
  end
end
