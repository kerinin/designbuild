class MaterialCost < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :project
  belongs_to :component
  belongs_to :task, :inverse_of => :material_costs
  belongs_to :supplier, :inverse_of => :material_costs
  
  has_many :line_items, :class_name => "MaterialCostLine", :foreign_key => :material_set_id, :order => :name, :dependent => :destroy
  
  validates_presence_of :task, :supplier, :date
  validates_numericality_of :raw_cost, :if => :raw_cost
  
  before_create :inherit_project
  
  before_save :cache_values
  
  before_save :auto_assign_component
  after_save :cascade_cache_values, :create_points
  after_destroy :cascade_cache_values
  
  scope :purchase_order, lambda {
    where(:raw_cost => nil)
  }

  scope :purchase, lambda {
    where('raw_cost IS NOT NULL')
  }
    
  scope :by_project, lambda {|project| joins(:task).where('tasks.project_id = ?', project.id) } 
  
  def markups
    self.task.markups
  end
  
  def supplier_name=(string)
    self.supplier = (string == '' || string.nil?) ? nil : Supplier.find_or_create_by_name(string)
  end
  
  def supplier_name
    self.supplier.blank? ? nil : self.supplier.name
  end

  def cache_values
    self.cost = add_or_nil self.raw_cost, self.markups.inject(0) {|memo,obj| add_or_nil memo, obj.apply_to(self, :raw_cost) }
  end
  
  def cascade_cache_values
    self.task.reload.save!
    
    Task.find(self.task_id_was).save! if self.task_id_changed? && !self.task_id_was.nil? && Task.exists?(:id => self.task_id_was)
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
  
  def inherit_project
    self.project = self.task.project
  end
  
  def auto_assign_component
    components = Component.scoped.includes(:fixed_cost_estimates, :unit_cost_estimates)
    
    # if the task has costs associated with it and they're all from the same component, assign the component to this cost
    components = components.where('fixed_cost_estimates.task_id = ?', self.task_id) unless self.task.fixed_cost_estimates.empty?
    components = components.where('unit_cost_estimates.task_id = ?', self.task_id) unless self.task.unit_cost_estimates.empty?
    
    self.component = components.first if components.count == 1
  end
end
