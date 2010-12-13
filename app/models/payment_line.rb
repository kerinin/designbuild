class PaymentLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :payment
  belongs_to :cost, :polymorphic => true
  
  validates_presence_of :payment, :cost
  validates_associated :payment
  
  def paid
    add_or_nil self.labor_paid, self.material_paid
  end
  
  def retained
    add_or_nil self.labor_retained, self.material_retained
  end
end
