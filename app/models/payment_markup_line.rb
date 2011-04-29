class PaymentMarkupLine < ActiveRecord::Base
    include AddOrNil

    belongs_to :payment, :inverse_of => :lines
    belongs_to :markup, :inverse_of => :payment_lines
    
    validates_presence_of :payment, :markup
    validates_associated :payment
    validates_numericality_of :labor_paid, :material_paid, :labor_retained, :material_retained

    before_save :set_sums
    after_save Proc.new {|pl| pl.payment(true).save }

    def set_defaults
      self.labor_paid = self.component.labor_outstanding
      self.material_paid = self.component.material_outstanding

      self.labor_retained = self.component.labor_retainage - self.component.labor_retained
      self.material_retained = self.component.material_retainage - self.component.material_retained
      self
    end

    protected

    def set_sums
      self.paid = self.labor_paid + self.material_paid
      self.retained = self.labor_retained + self.material_retained
    end
  end
