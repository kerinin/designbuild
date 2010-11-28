class MaterialCost < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail
  
  belongs_to :task
  belongs_to :supplier
  
  has_many :line_items, :class_name => "MaterialCostLine", :foreign_key => :material_set_id, :order => :name, :dependent => :destroy
  
  validates_presence_of :task, :supplier, :date
  validates_numericality_of :raw_cost, :if => :raw_cost
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  def supplier_name=(string)
    self.supplier = Supplier.find_or_create_by_name(string) unless string == '' || string.nil?
  end
  
  def supplier_name
    self.supplier.blank? ? nil : self.supplier.name
  end
  
  def total_markup
    self.task.total_markup unless self.task.blank?
  end
  
  # cost
  marks_up :raw_cost
  
  # raw_cost

  def cascade_cache_values
    self.task.save!
  end
end
