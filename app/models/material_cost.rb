class MaterialCost < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :task, :inverse_of => :material_costs
  belongs_to :supplier, :inverse_of => :material_costs
  
  has_many :line_items, :class_name => "MaterialCostLine", :foreign_key => :material_set_id, :order => :name, :dependent => :destroy
  
  validates_presence_of :task, :supplier, :date
  validates_numericality_of :raw_cost, :if => :raw_cost
  
  before_save :cache_values, :if => :id
  after_create :cache_values
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  scope :purchase_order, lambda {
    where(:raw_cost => nil)
  }

  scope :purchase, lambda {
    where('raw_cost IS NOT NULL')
  }
    
  scope :by_project, lambda {|project| joins(:task).where('tasks.project_id = ?', project.id) } 
  
  def supplier_name=(string)
    self.supplier = (string == '' || string.nil?) ? nil : Supplier.find_or_create_by_name(string)
  end
  
  def supplier_name
    self.supplier.blank? ? nil : self.supplier.name
  end
  
  def total_markup
    self.task.total_markup unless self.task.blank?
  end
  
  # cost
  #marks_up :raw_cost
  
  # raw_cost

  def cache_values
    self.cost = mark_up self.raw_cost
  end
  
  def cascade_cache_values
    #puts "cascading from mc"
    self.task.save!
    
    Task.find(self.task_id_was).save! if self.task_id_changed? && !self.task_id_was.nil?
  end
end
