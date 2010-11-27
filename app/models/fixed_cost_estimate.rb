class FixedCostEstimate < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :component
  belongs_to :task
  
  validates_presence_of :name, :raw_cost, :component
  
  validates_numericality_of :raw_cost
  
  after_save :cache_values
  after_destroy :cache_values
  
  scope :unassigned, lambda { where( {:task_id => nil} ) }
  
  def task_name=(string)
    self.task = Task.find_or_create_by_name(string, :project => self.component.project) unless string == '' || string.nil?
  end
  
  def task_name
    self.task.blank? ? nil : self.task.name
  end
  
  def cost
    multiply_or_nil self.raw_cost, (1+(self.component.total_markup/100))
  end
  
  # raw_cost
  
  private
  
  def cache_values
    self.component.cache_values
    self.task.cache_values
  end
end
