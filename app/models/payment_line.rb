class PaymentLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :payment
  belongs_to :cost, :polymorphic => true
  
  validates_presence_of :payment, :cost
  validates_associated :payment
  
  before_save :set_defaults
  
  def paid
    add_or_nil self.labor_paid, self.material_paid
  end
  
  def retained
    add_or_nil self.labor_retained, self.material_retained
  end
  
  protected
  
  def set_defaults
    self.labor_paid ||= self.cost.labor_outstanding
    self.material_paid ||= self.cost.material_outstanding
    
    self.labor_retained ||= subtract_or_nil( self.cost.labor_retainage, self.cost.labor_retained )
    self.material_retained ||= subtract_or_nil( self.cost.material_retainage, self.cost.material_retained )
  end
end
