class AddCostReconciled < ActiveRecord::Migration
  def self.up
    add_column :contract_costs, :reconciled, :boolean
    add_column :labor_costs, :reconciled, :boolean
    add_column :material_costs, :reconciled, :boolean
  end

  def self.down
    remove_column :contract_costs, :reconciled
    remove_column :labor_costs, :reconciled
    remove_column :material_costs, :reconciled
  end
end
