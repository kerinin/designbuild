class AddZeroDefaultInvoicesPaymentsLines < ActiveRecord::Migration
  class InvoiceLine < ActiveRecord::Base
  end

  class Project < ActiveRecord::Base
  end
  
  class PaymentLine < ActiveRecord::Base
  end 

  def self.up
    InvoiceLine.all.each {|i| i.labor_invoiced ||= 0; i.material_invoiced ||= 0; i.labor_retainage ||= 0; i.material_retainage ||= 0; i.save}
    Project.all.each {|i| i.labor_percent_retainage ||= 0; i.material_percent_retainage ||= 0; i.save}
    PaymentLine.all.each {|i| i.labor_paid ||= 0; i.material_paid ||= 0; i.labor_retained ||= 0; i.material_retained ||= 0; i.save}
    
    
    change_column :invoice_lines, :labor_invoiced, :float, :null => false, :default => 0
    change_column :invoice_lines, :material_invoiced, :float, :null => false, :default => 0
    change_column :invoice_lines, :labor_retainage, :float, :null => false, :default => 0
    change_column :invoice_lines, :material_retainage, :float, :null => false, :default => 0
    
    change_column :projects, :labor_percent_retainage, :float, :null => false, :default => 0
    change_column :projects, :material_percent_retainage, :float, :null => false, :default => 0
    
    change_column :payment_lines, :labor_paid, :float, :null => false, :default => 0
    change_column :payment_lines, :material_paid, :float, :null => false, :default => 0
    change_column :payment_lines, :labor_retained, :float, :null => false, :default => 0
    change_column :payment_lines, :material_retained, :float, :null => false, :default => 0
  end

  def self.down
    change_column :invoice_lines, :labor_invoiced, :float, :null => true, :default => nil
    change_column :invoice_lines, :material_invoiced, :float, :null => true, :default => nil
    change_column :invoice_lines, :labor_retainage, :float, :null => true, :default => nil
    change_column :invoice_lines, :material_retainage, :float, :null => true, :default => nil
    
    change_column :projects, :labor_percent_retainage, :float, :null => true, :default => nil
    change_column :projects, :material_percent_retainage, :float, :null => true, :default => nil
    
    change_column :payment_lines, :labor_paid, :float, :null => true, :default => nil
    change_column :payment_lines, :material_paid, :float, :null => true, :default => nil
    change_column :payment_lines, :labor_retained, :float, :null => true, :default => nil
    change_column :payment_lines, :material_retained, :float, :null => true, :default => nil
  end
end
