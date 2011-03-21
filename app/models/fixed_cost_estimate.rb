class FixedCostEstimate < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  #has_invoices
  
  belongs_to :component, :inverse_of => :fixed_cost_estimates, :autosave => true
  belongs_to :task, :inverse_of => :fixed_cost_estimates, :autosave => true
  
  validates_presence_of :name, :raw_cost, :component
  
  validates_numericality_of :raw_cost
  
  before_save :cache_values
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  scope :unassigned, lambda { where( {:task_id => nil} ) }
  
  scope :assigned, lambda { where( 'task_id IS NOT NULL' ) }
  
  def markups
    self.component.markups
  end
  
  def task_name=(string)
    self.task = (string == '' || string.nil?) ? nil : Task.find_or_create_by_name_and_project_id(string, self.component.project_id)
  end
  
  def task_name
    self.task.blank? ? nil : self.task.name
  end
  
  def estimated_cost
    self.cost
  end
  
  def estimated_raw_cost
    self.raw_cost
  end

  # Invoicing
  [:labor_cost, :material_cost].each do |sym|
    self.send(:define_method, sym) do
      if self.task.blank? || self.task.send(sym).nil? || self.estimated_cost.nil? 
        0
      else
        task_cost = self.task.send(sym)
        my_share = case
        when task.unit_cost_estimates.count + task.fixed_cost_estimates.count == 1
          1
        when !self.estimated_cost.nil? && self.task.estimated_cost > 0
          self.estimated_cost / self.task.estimated_cost
        else
          1 / (self.task.unit_cost_estimates.count + self.task.fixed_cost_estimates)
        end
        
        return task_cost * my_share
      end
    end
  end
  
  [:labor_cost_before, :material_cost_before].each do |sym|
    self.send(:define_method, sym) do |date|
      date ||= Date::today
      if self.task.blank? || self.task.send(sym, date).nil? || self.estimated_cost.nil?
        0
      else
        task_cost = self.task.send(sym, date)
        my_share = case
        when task.unit_cost_estimates.count + task.fixed_cost_estimates.count == 1
          1
        when !self.estimated_cost.nil? && self.task.estimated_cost > 0
          self.estimated_cost / self.task.estimated_cost
        else
          1 / (self.task.unit_cost_estimates.count + self.task.fixed_cost_estimates)
        end
        
        return task_cost * my_share
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
  
  def cache_values
    self.cost = self.raw_cost + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_cost) }
  end
  
  def cascade_cache_values
    self.component.reload.save!
    self.task.reload.save! unless self.task.blank?
    
    Component.find(self.component_id_was).save! if self.component_id_changed? && !self.component_id_was.nil? && Component.exists?(:id => self.component_id_was)
    Task.find(self.task_id_was).save! if self.task_id_changed? && !self.task_id_was.nil? && Task.exists?(:id => self.task_id_was)
  end
end
