class PaymentMarkupLine < ActiveRecord::Base
  include AddOrNil

  belongs_to :payment, :inverse_of => :markup_lines
  belongs_to :markup, :inverse_of => :payment_markup_lines
  
  validates_presence_of :payment, :markup
  validates_associated :payment
  validates_numericality_of :labor_paid, :material_paid, :labor_retained, :material_retained

  before_create :set_defaults
  before_save :set_sums
  after_save Proc.new {|pl| pl.payment(true).save }

  # NOTE: this needs work...  should be the difference between invoiced and paid
  def set_defaults
    [:labor_paid, :labor_retained, :material_paid, :material_retained].each do |sym|
      #self.send("#{sym.to_s}=", self.markup.apply_to(self.payment.lines.includes(:component => :markups).where('markups.id = ?', self.markup_id).sum(sym)))
      self.send("#{sym.to_s}=", 0)
    end
    self.set_sums
  end
  
  protected

  def set_sums
    self.paid = self.labor_paid + self.material_paid
    self.retained = self.labor_retained + self.material_retained
  end
end
