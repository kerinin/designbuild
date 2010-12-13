require 'has_invoices/instance_methods'
require 'has_invoices/class_methods'

class << ActiveRecord::Base
  def has_invoices options = {}
    
    has_many :invoice_lines, :as => :cost
    has_many :payment_lines, :as => :cost

    [:invoiced, :retainage, :labor_invoiced, :labor_retainage, :material_invoiced, :material_retainage].each do |sym|
      self.send(:define_method, sym) do
        self.invoice_lines.inject(nil) {|memo,obj| add_or_nil memo, obj.send(sym)}
      end
    end

    [:paid, :retained, :labor_paid, :labor_retained, :material_paid, :material_retained].each do |sym|
      self.send(:define_method, sym) do
        self.payment_lines.inject(nil) {|memo,obj| add_or_nil memo, obj.send(sym)}
      end
    end
    
    # Include instance methods
    include HasInvoices::InstanceMethods

    # Include dynamic class methods
    extend HasInvoices::ClassMethods
  end
end
