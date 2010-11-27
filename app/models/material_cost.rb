class MaterialCost < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :task
  belongs_to :supplier
  
  has_many :line_items, :class_name => "MaterialCostLine", :foreign_key => :material_set_id, :order => :name, :dependent => :destroy, :after_add => :cache_values, :after_remove => :cache_values
  
  validates_presence_of :task, :supplier, :date
  validates_numericality_of :raw_cost, :if => :raw_cost
  
  after_save :cache_values
  after_destroy :cache_values
  
  def supplier_name=(string)
    self.supplier = Supplier.find_or_create_by_name(string) unless string == '' || string.nil?
  end
  
  def supplier_name
    self.supplier.blank? ? nil : self.supplier.name
  end
  
  
  def cost
    multiply_or_nil self.raw_cost, (1+(self.task.total_markup/100))
  end
  
  # raw_cost
  
  private
  
  def cache_values
    self.task.cache_values
  end
end
