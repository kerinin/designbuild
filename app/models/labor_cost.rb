class LaborCost < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :project
  belongs_to :task, :inverse_of => :labor_costs
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy
  
  validates_presence_of :task, :percent_complete, :date
  validates_numericality_of :percent_complete
  
  before_save :set_project, :cache_values
  
  after_save :deactivate_task_if_done
  after_save :set_task_percent_complete
  
  after_save :cascade_cache_values, :create_points
  after_destroy :cascade_cache_values
  
  scope :by_project, lambda {|project| where(:project_id => project.id ) } 

  def markups
    self.task.markups
  end
  
  def cache_values
    self.line_items.reload
    
    self.cache_cost
  end
  
  def cascade_cache_values
    self.task.reload.save!
    
    Task.find(self.task_id_was).save! if self.task_id_changed? && !self.task_id_was.nil?
  end

  protected
    
  def set_project
    self.project = self.task.project
  end
  
  def cache_cost
    self.raw_cost = self.line_items.sum(:raw_cost)
    self.cost = self.raw_cost + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_cost) }
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
  
  def create_points
    self.task.project.create_cost_to_date_points(self.date)
    self.task.create_cost_to_date_points(self.date)
    
    #p = self.task.project.cost_to_date_points.find_or_create_by_date(self.date)
    #if p.label.nil?
    #  p.series = :cost_to_date
    #  p.value = self.task.project.labor_cost_before(self.date) + self.task.project.material_cost_before(self.date)
    #  p.save!
    #end

    #p = self.task.cost_to_date_points.find_or_create_by_date(self.date)
    #if p.label.nil?
    #  p.series = :cost_to_date
    #  p.value = self.task.labor_cost_before(self.date) + self.task.material_cost_before(self.date)
    #  p.save!
    #end
  end
end
