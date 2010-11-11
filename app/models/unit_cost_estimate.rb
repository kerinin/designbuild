class UnitCostEstimate < ActiveRecord::Base
  belongs_to :component
  belongs_to :quantity, :polymorphic => true

  validates_presence_of :quantity
  
  after_validation :set_component
  private
  
  def set_component
    self.component = self.quantity.component
  end
end
