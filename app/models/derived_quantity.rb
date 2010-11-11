class DerivedQuantity < ActiveRecord::Base
  belongs_to :parent_quantity, :class_name => "Quantity"
  
  has_one :component, :through => :parent_quantity
  
  validates_presence_of :parent_quantity
end
