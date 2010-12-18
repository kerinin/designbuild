class AddZeroDefaultInvoicesPaymentsLines < ActiveRecord::Migration
  def self.up
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
