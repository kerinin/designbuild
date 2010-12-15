class FixedCostEstimate < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail
  has_invoices
  
  belongs_to :component
  belongs_to :task
  
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
  
  def estimated_cost
    cost
  end
  
  def estimated_raw_cost
    raw_cost
  end
  
  # cost
  marks_up :raw_cost
  
  # raw_cost

  # Invoicing
  [:labor_cost, :material_cost].each do |sym|
    self.send(:define_method, sym) do
      if self.task.blank? || self.task.send(sym).nil? || self.cost.nil? 
        nil
      else
        self.task.send(sym.to_s.gsub('cost', 'percent')) * self.cost / 100
      end
    end
  end
  
  [:labor_cost_before, :material_cost_before].each do |sym|
    self.send(:define_method, sym) do |date|
      date ||= Date::today
      if self.task.blank? || self.task.send(sym, date).nil? || self.cost.nil?
        nil
      else
        self.task.send(sym.to_s.gsub('cost', 'percent'), date) * self.cost / 100
      end
    end
  end
  
  def percent_complete
    self.task.percent_complete unless self.task.blank?
  end
  
  def percent_complete_float
    self.task.percent_complete_float unless self.task.blank?
  end
  
  protected
  
  def cascade_cache_values
    self.component.reload.save!
    self.task.reload.save! unless self.task.blank?
    
    Component.find(self.component_id_was).save! if self.component_id_changed? && !self.component_id_was.nil?
    Task.find(self.task_id_was).save! if self.task_id_changed? && !self.task_id_was.nil?
  end
end
