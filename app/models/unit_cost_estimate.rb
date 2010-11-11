class UnitCostEstimate < ActiveRecord::Base
  belongs_to :component
  belongs_to :quantity
end
