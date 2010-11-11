class Quantity < ActiveRecord::Base
  belongs_to :component
  
  has_many :derived_quantities, :foreign_key => :parent_quantity_id
  has_many :unit_cost_estimates
  
  validates_presence_of :component
end
