class FixedCostEstimate < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail
  
  belongs_to :component
  belongs_to :task
  
  validates_presence_of :name, :raw_cost, :component
  
  validates_numericality_of :raw_cost
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  scope :unassigned, lambda { where( {:task_id => nil} ) }
  
  def task_name=(string)
    self.task = Task.find_or_create_by_name(string, :project => self.component.project) unless string == '' || string.nil?
  end
  
  def task_name
    self.task.blank? ? nil : self.task.name
  end
  
  marks_up :raw_cost
  #def cost
  #  multiply_or_nil self.raw_cost, (1+(self.component.total_markup/100))
  #end
  
  # raw_cost

  def cascade_cache_values
    self.component.save!
    self.task.save! unless self.task.blank?
  end
end
