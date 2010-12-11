class FixedCostEstimate < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail
  
  belongs_to :component
  belongs_to :task
  
  has_many :invoice_lines, :as => :cost
  
  validates_presence_of :name, :raw_cost, :component
  
  validates_numericality_of :raw_cost
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  scope :unassigned, lambda { where( {:task_id => nil} ) }
  
  scope :assigned, lambda { where( 'task_id IS NOT NULL' ) }
  
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


  # Invoicing
  [:labor_cost, :material_cost].each do |sym|
    self.send(:define_method, sym) do
      self.task.blank? || self.task.send(sym).nil? || self.cost.nil? ? nil : self.task.send(sym) * self.cost / self.task.estimated_cost
    end
  end
  
  # percent_complete
  
  # invoiced
  # retainage
  # paid
  # retained
  
  # labor_percent
  # labor_invoiced
  # labor_retainage
  # labor_paid
  # labor_retained
  
  # material_percent
  # material_invoiced
  # material_retainage
  # material_paid
  # material_retained
  
  protected
  
  def cascade_cache_values
    self.component.reload.save!
    self.task.reload.save! unless self.task.blank?
    
    Component.find(self.component_id_was).save! if self.component_id_changed? && !self.component_id_was.nil?
    Task.find(self.task_id_was).save! if self.task_id_changed? && !self.task_id_was.nil?
  end
end
