class NewInvoicing < ActiveRecord::Migration
  def self.up
    add_column :invoice_lines, :component_id, :integer
    add_column :invoice_lines, :invoiced, :float, :default => 0
    add_column :invoice_lines, :retainage, :float, :default => 0
    
    add_column :payment_lines, :component_id, :integer
    add_column :payment_lines, :paid, :float, :default => 0
    add_column :payment_lines, :retained, :float, :default => 0
  end

  def self.down
    remove_column :invoice_lines, :component_id, :integer
    remove_column :payment_lines, :component_id
  end
end
