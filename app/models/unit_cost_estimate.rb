class UnitCostEstimate < ActiveRecord::Base
  belongs_to :component
  belongs_to :quantity
  belongs_to :task

  validates_presence_of :name, :quantity, :unit_cost
  validates_numericality_of :unit_cost
  
  before_save :set_component
  
  scope :unassigned, lambda { where( {:task_id => nil} ) }
  
  def cost
    self.quantity.value * self.unit_cost * ( self.drop.nil? ? 1 : (1.0 + (self.drop / 100.0) ) )
  end
  
  private
  
  def set_component
    self.component ||= self.quantity.component
  end
end
