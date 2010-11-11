class DerivedQuantity < ActiveRecord::Base
  belongs_to :component
  belongs_to :parent_quantity, :class_name => "Quantity"
end
