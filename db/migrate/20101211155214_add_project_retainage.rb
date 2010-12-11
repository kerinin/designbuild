class AddProjectRetainage < ActiveRecord::Migration
  def self.up
    add_column :projects, :labor_percent_retainage, :float
    add_column :projects, :material_percent_retainage, :float
    add_column :projects, :contract_percent_retainage, :float
    add_column :projects, :fixed_bid, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :labor_percent_retainage
    remove_column :projects, :material_percent_retainage
    remove_column :projects, :contract_percent_retainage
    remove_column :projects, :fixed_bid
  end
end
