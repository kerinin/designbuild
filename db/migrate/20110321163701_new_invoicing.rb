class NewInvoicing < ActiveRecord::Migration
  def self.up
    add_column :invoice_lines, :component_id, :integer
    add_column :payment_lines, :component_id, :integer
  end

  def self.down
    remove_column :invoice_lines, :component_id, :integer
    remove_column :payment_lines, :component_id
  end
end
