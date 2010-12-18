require 'has_invoices/instance_methods'
require 'has_invoices/class_methods'

class << ActiveRecord::Base
  def has_invoices options = {}
    
    has_many :invoice_lines, :as => :cost
    has_many :payment_lines, :as => :cost

    [:invoiced, :retainage, :labor_invoiced, :labor_retainage, :material_invoiced, :material_retainage].each do |sym|
      self.send(:define_method, sym) do
        self.invoice_lines.includes(:invoice).inject(0) {|memo,obj| memo + obj.send(sym)}
      end
    end

    [:invoiced_before, :retainage_before, :labor_invoiced_before, :labor_retainage_before, :material_invoiced_before, :material_retainage_before].each do |sym|
      self.send(:define_method, sym) do |date|
        date ||= Date::today
        self.invoice_lines.includes(:invoice).where('invoices.date <= ?', date).inject(0) {|memo,obj| memo + obj.send(sym.to_s.split('_before').first)}
      end
    end
    
    [:paid, :retained, :labor_paid, :labor_retained, :material_paid, :material_retained].each do |sym|
      self.send(:define_method, sym) do
        self.payment_lines.inject(0) {|memo,obj| memo + obj.send(sym)}
      end
    end
    
    [:paid_before, :retained_before, :labor_paid_before, :labor_retained_before, :material_paid_before, :material_retained_before].each do |sym|
      self.send(:define_method, sym) do |date|
        date ||= Date::today
        self.payment_lines.includes(:payment).where('payments.date <= ?', date).inject(0) {|memo,obj| memo + obj.send(sym.to_s.split('_before').first)}
      end
    end
    
    # Include instance methods
    include HasInvoices::InstanceMethods

    # Include dynamic class methods
    extend HasInvoices::ClassMethods
  end
end
