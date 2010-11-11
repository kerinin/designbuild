class UnitCostEstimate < ActiveRecord::Base
  belongs_to :component
  belongs_to :quantity, :polymorphic => true
  belongs_to :task

  validates_presence_of :quantity
  
  before_save :set_component
  
  private
  
  def set_component
    self.component = self.quantity.component
  end
end
