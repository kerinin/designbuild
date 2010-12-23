class LaborCost < ActiveRecord::Base
  include AddOrNil
  include MarksUp
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :task, :inverse_of => :labor_costs
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy
  
  validates_presence_of :task, :percent_complete
  validates_numericality_of :percent_complete
  
  before_save :cache_values
  
  after_save :deactivate_task_if_done
  after_save :set_task_percent_complete
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  scope :by_project, lambda {|project| joins(:task).where('tasks.project_id = ?', project.id) } 
  
  def total_markup
    self.task.total_markup unless self.task.blank?
  end
  
  # cost
  marks_up :raw_cost
  
  # raw_cost
  
  def cache_values
    self.line_items.reload
    
    self.cache_raw_cost
  end
  
  def cascade_cache_values
    self.task.reload.save!
    
    Task.find(self.task_id_was).save! if self.task_id_changed? && !self.task_id_was.nil?
  end

  protected
    
  def cache_raw_cost
    self.raw_cost = self.line_items.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  end
  
  def deactivate_task_if_done
    self.task.active = false if self.percent_complete >= 100
    self.task.save!
  end
  
  def set_task_percent_complete
    if self.task.labor_costs.order(:date).first == self
      self.task.percent_complete = self.percent_complete 
      self.task.save!
    end
  end
end
