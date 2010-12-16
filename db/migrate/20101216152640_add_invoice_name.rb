class AddInvoiceName < ActiveRecord::Migration
  def self.up
    add_column :invoices, :name, :string
  end

  def self.down
    remove_column :invoices, :name
  end
end
