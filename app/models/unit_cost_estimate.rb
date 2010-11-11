class UnitCostEstimate < ActiveRecord::Base
  belongs_to :component
  belongs_to :quantity
  
  validates_presence_of :component, :quantity
end
