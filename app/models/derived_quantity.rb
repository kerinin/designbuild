class DerivedQuantity < ActiveRecord::Base
  belongs_to :component
  belongs_to :parent_quantity, :class_name => "Quantity"
  
  has_many :unit_cost_estimates, :as => :quantity
  
  validates_presence_of :parent_quantity, :multiplier
  
  before_save :set_component
  
  def value
    self.multiplier * self.parent_quantity.value
  end
  
  private
  
  def set_component
    self.component = self.parent_quantity.component
  end
end
