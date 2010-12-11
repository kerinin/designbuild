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
    self.task = (string == '' || string.nil?) ? nil : Task.find_or_create_by_name(string, :project => self.component.project)
  end
  
  def task_name
    self.task.blank? ? nil : self.task.name
  end
  
  def total_markup
    self.component.total_markup unless self.component.blank?
  end
  
  # cost
  marks_up :raw_cost
  
  # raw_cost
  
  
  def cache_values
    self.quantity.reload
    
    self.cache_cost
  end
  
  def cascade_cache_values
    self.component.reload.save!
    self.task.reload.save! unless self.task.blank?
    
    Component.find(self.component_id_was).save! if self.component_id_changed? && !self.component_id_was.nil?
    Task.find(self.task_id_was).save! if self.task_id_changed? && !self.task_id_was.nil?    
  end
  
  
  protected
    
  def cache_cost
    self.raw_cost = self.quantity.value * self.unit_cost * ( self.drop.nil? ? 1 : (1.0 + (self.drop / 100.0) ) )
  end
  
  def set_component
    self.component ||= self.quantity.component
  end
end
