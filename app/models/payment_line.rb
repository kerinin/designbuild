class PaymentLine < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :payment
  belongs_to :cost, :polymorphic => true
  
  validates_presence_of :payment, :cost
  validates_associated :payment
  validates_numericality_of :labor_paid, :material_paid, :labor_retained, :material_retained
  
  before_validation :set_defaults
  after_update Proc.new {|payline| payline.payment.save! }
  
  def paid
    self.labor_paid + self.material_paid
  end
  
  def retained
    self.labor_retained + self.material_retained
  end
  
  protected
  
  def set_defaults
    unless self.cost.nil?
      self.labor_paid ||= self.cost.labor_outstanding
      self.material_paid ||= self.cost.material_outstanding
      
      self.labor_retained ||= self.cost.labor_retainage - self.cost.labor_retained
      self.material_retained ||= self.cost.material_retainage - self.cost.material_retained
    end
  end
end
