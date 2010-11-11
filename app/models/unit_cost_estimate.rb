class UnitCostEstimate < ActiveRecord::Base
  belongs_to :component
  belongs_to :quantity, :polymorphic => true

  validates_presence_of :quantity
end
