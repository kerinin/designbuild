class MaterialCost < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :project
  belongs_to :component
  belongs_to :task, :inverse_of => :material_costs
  belongs_to :supplier, :inverse_of => :material_costs
  
  has_many :line_items, :class_name => "MaterialCostLine", :foreign_key => :material_set_id, :order => :name, :dependent => :destroy
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
  
  validates_presence_of :task, :supplier, :date
  validates_numericality_of :raw_cost, :if => :raw_cost
  
  before_save :set_project, :cache_values  
  before_save :auto_assign_component
  before_save :update_markings, :if => proc {|i| i.component_id_changed? }, :unless => proc {|i| i.markings.empty? }
  
  #after_save :create_points
  after_save :advance_invoicing, :if => Proc.new {|mc| mc.component_id_changed?}
  
  scope :purchase_order, lambda {
    where(:raw_cost => nil)
  }

  scope :purchase, lambda {
    where('raw_cost IS NOT NULL')
  }
    
  scope :unassigned, lambda {
    where(:component_id => nil)
  }
    
  scope :by_project, lambda {|project| joins(:task).where('tasks.project_id = ?', project.id) } 
  
  def update_markings
    self.markings.update_all(:component_id => self.component_id)
  end
  
  def cost
    self.raw_cost + self.markings.sum(:cost_markup_amount)
  end
  
  def markups
    self.task.markups
  end
  
  def supplier_name=(string)
    self.supplier = (string == '' || string.nil?) ? nil : Supplier.find_or_create_by_name(string)
  end
  
  def supplier_name
    self.supplier.blank? ? nil : self.supplier.name
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
  
  protected
  
  def advance_invoicing
    self.project.invoices.each {|i| i.advance!}
    self.project.payments.each {|i| i.advance!}
  end
  
  def set_project
    self.project = self.task.project
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
end
