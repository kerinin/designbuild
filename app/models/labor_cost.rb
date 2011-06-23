class LaborCost < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :project
  belongs_to :component
  belongs_to :task, :inverse_of => :labor_costs
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy
  
  validates_presence_of :task, :percent_complete, :date
  validates_numericality_of :percent_complete
  
  before_save :set_project
  before_save :auto_assign_component
  
  after_save :deactivate_task_if_done
  after_save :set_task_percent_complete
  
  #after_save :create_points
  after_save :advance_invoicing, :if => Proc.new {|mc| mc.component_id_changed?}
  
  scope :by_project, lambda {|project| where(:project_id => project.id ) }
  
  scope :unassigned, lambda {
    where(:component_id => nil)
  }
  
  def cost
    raw_cost + self.line_items.joins(:markings).sum('markings.cost_markup_amount').to_f
  end

  def raw_cost
    self.line_items.sum('labor_cost_lines.raw_cost').to_f
  end
    
  def markups
    self.task.markups
  end

  protected
  
  def advance_invoicing
    self.project.invoices.each {|i| i.advance!}
    self.project.payments.each {|i| i.advance!}
  end
  
  def auto_assign_component
    # If the task has no estimated costs, it can't have a component association
    return if self.task.fixed_cost_estimates.empty? && self.task.unit_cost_estimates.empty?
    
    components = Component.scoped.includes(:fixed_cost_estimates, :unit_cost_estimates)
    
    # if the task has costs associated with it and they're all from the same component, assign the component to this cost
    components = components.where('fixed_cost_estimates.task_id = ?', self.task_id) unless self.task.fixed_cost_estimates.empty?
    components = components.where('unit_cost_estimates.task_id = ?', self.task_id) unless self.task.unit_cost_estimates.empty?
    
    self.component = components.first if components.count == 1
  end
  
  def set_project
    self.project = self.task.project
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
