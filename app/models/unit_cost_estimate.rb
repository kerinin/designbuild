class UnitCostEstimate < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail
  
  belongs_to :component
  belongs_to :quantity
  belongs_to :task

  validates_presence_of :name, :quantity, :unit_cost
  validates_numericality_of :unit_cost
  
  before_save :set_component
  
  before_save :cache_values
  
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
  #  multiply_or_nil self.raw_cost, (1 + (self.component.total_markup / 100) )
  #end
  
  # raw_cost
  
  
  def cache_values
    self.quantity.reload
    
    self.cache_cost
  end
  
  def cascade_cache_values
    self.component.save!
  end
  
  
  protected
    
  def cache_cost
    self.raw_cost = self.quantity.value * self.unit_cost * ( self.drop.nil? ? 1 : (1.0 + (self.drop / 100.0) ) )
  end
  
  def set_component
    self.component ||= self.quantity.component
  end
end
