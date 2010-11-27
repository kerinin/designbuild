class MaterialCost < ActiveRecord::Base
  has_paper_trail
  
  belongs_to :task
  belongs_to :supplier
  
  has_many :line_items, :class_name => "MaterialCostLine", :foreign_key => :material_set_id, :order => :name, :dependent => :destroy
  
  validates_presence_of :task, :supplier, :date
  
  def supplier_name=(string)
    self.supplier = Supplier.find_or_create_by_name(string) unless string == '' || string.nil?
  end
  
  def supplier_name
    self.supplier.blank? ? nil : self.supplier.name
  end
end
