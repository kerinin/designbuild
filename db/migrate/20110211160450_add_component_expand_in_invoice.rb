class AddComponentExpandInInvoice < ActiveRecord::Migration
  def self.up
    add_column :components, :expand_in_invoice, :boolean, :default => false
  end

  def self.down
    remove_column :components, :expand_in_invoice
  end
end
