class Quantity < ActiveRecord::Base
  belongs_to :component
  
  has_many :unit_cost_estimates
  
  validates_presence_of :component, :value
end
