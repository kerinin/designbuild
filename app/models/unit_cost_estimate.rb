class UnitCostEstimate < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :component
  belongs_to :quantity
  belongs_to :task

  validates_presence_of :name, :quantity, :unit_cost
  validates_numericality_of :unit_cost
  
  before_save :set_component
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
    multiply_or_nil self.raw_cost, (1 + (self.component.total_markup / 100) )
  end
  
  # raw_cost
  
  
  private
  
  def cache_values
    self.cache_cost
    
    self.component.cache_values
    self.task.cache_values
  end
  
  def cache_cost
    self.raw_cost = self.quantity.value * self.unit_cost * ( self.drop.nil? ? 1 : (1.0 + (self.drop / 100.0) ) )
  end
  
  def set_component
    self.component ||= self.quantity.component
  end
end
