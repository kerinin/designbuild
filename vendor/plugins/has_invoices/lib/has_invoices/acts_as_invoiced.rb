require 'has_invoices/instance_methods'
require 'has_invoices/class_methods'

class << ActiveRecord::Base
  def has_invoices options = {}
    
    has_many :invoice_lines, :as => :cost

    [:invoiced, :retainage, :paid, :retained, :labor_invoiced, :labor_retainage, :labor_paid, :labor_retained, :material_invoiced, :material_retainage, :material_paid, :material_retained].each do |sym|
      self.send(:define_method, sym) do
        self.invoice_lines.inject(nil) {|memo,obj| add_or_nil memo, obj.send(sym)}
      end
    end

    # Include instance methods
    include HasInvoices::InstanceMethods

    # Include dynamic class methods
    extend HasInvoices::ClassMethods
  end
end