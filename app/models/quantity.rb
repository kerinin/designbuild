class Quantity < ActiveRecord::Base
  belongs_to :component
  
  has_many :derived_quantities, :foreign_key => :parent_quantity_id
  has_many :unit_cost_estimates, :as => :quantity
  
  validates_presence_of :component, :value
end
