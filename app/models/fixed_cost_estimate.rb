class FixedCostEstimate < ActiveRecord::Base
  belongs_to :component
  belongs_to :task
  
  validates_presence_of :name, :cost, :component
  
  validates_numericality_of :cost
  
  scope :unassigned, lambda { where( {:task_id => nil} ) }
  
  def task_name=(string)
    self.task = Task.find_or_create_by_name(string, :project => self.component.project)
  end
  
  def task_name
    self.task.blank? ? nil : self.task.name
  end
  
  def marked_up_cost
    (1 + (self.component.total_markup / 100) ) * self.cost
  end
end
