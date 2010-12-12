class RenameContractCosts < ActiveRecord::Migration
  def self.up
    rename_column :contracts, :raw_cost, :estimated_raw_cost
    rename_column :contracts, :raw_invoiced, :raw_cost
    remove_column :projects, :contract_invoiced
    remove_column :projects, :raw_contract_invoiced
  end

  def self.down
    rename_column :contracts, :estimated_raw_cost, :raw_cost
    rename_column :contracts, :raw_cost, :raw_invoiced
    add_column :projects, :contract_invoiced, :float
    add_column :projects, :raw_contract_invoiced, :float
  end
end
