class UnitCostEstimate < ActiveRecord::Base
  belongs_to :component
  belongs_to :quantity, :polymorphic => true
  belongs_to :task

  validates_presence_of :quantity, :unit_cost
  
  before_save :set_component
  
  def cost
    self.quantity.value * self.unit_cost
  end
  
  private
  
  def set_component
    self.component = self.quantity.component
  end
end
