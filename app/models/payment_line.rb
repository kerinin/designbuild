class PaymentLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :payment, :inverse_of => :lines
  belongs_to :cost, :polymorphic => true
  
  validates_presence_of :payment, :cost
  validates_associated :payment
  validates_numericality_of :labor_paid, :material_paid, :labor_retained, :material_retained
  
  after_save Proc.new {|pl| pl.payment(true).save }
  
  def paid
    self.labor_paid + self.material_paid
  end
  
  def retained
    self.labor_retained + self.material_retained
  end
  
  def set_defaults
    self.labor_paid = self.cost.labor_outstanding
    self.material_paid = self.cost.material_outstanding
    
    self.labor_retained = self.cost.labor_retainage - self.cost.labor_retained
    self.material_retained = self.cost.material_retainage - self.cost.material_retained
    self
  end
end
