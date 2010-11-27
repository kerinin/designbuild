class AddCachedValues < ActiveRecord::Migration
  def self.up
  
    rename_column :bids, :cost, :raw_cost
    rename_column :contract_costs, :cost, :raw_cost
    rename_column :fixed_cost_estimates, :cost, :raw_cost
    rename_column :material_costs, :cost, :raw_cost
  
    # NOTE: total markup should only be applied laterally - subcomponents could have different markup
    add_column :components, :estimated_fixed_cost, :float
    add_column :components, :estimated_unit_cost, :float
    add_column :components, :estimated_raw_fixed_cost, :float
    add_column :components, :estimated_raw_unit_cost, :float
    add_column :components, :total_markup, :float
    
    add_column :contracts, :raw_cost, :float
    add_column :contracts, :raw_invoiced, :float
    add_column :contracts, :total_markup, :float
    
    add_column :labor_costs, :raw_cost, :float
    
    add_column :projects, :estimated_fixed_cost, :float
    add_column :projects, :estimated_raw_fixed_cost, :float
    add_column :projects, :estimated_unit_cost, :float
    add_column :projects, :estimated_raw_unit_cost, :float
    add_column :projects, :estimated_contract_cost, :float
    add_column :projects, :estimated_raw_contract_cost, :float
    add_column :projects, :material_cost, :float
    add_column :projects, :raw_material_cost, :float
    add_column :projects, :labor_cost, :float
    add_column :projects, :raw_labor_cost, :float
    add_column :projects, :contract_cost, :float
    add_column :projects, :raw_contract_cost, :float
    add_column :projects, :projected_cost, :float
    add_column :projects, :raw_projected_cost, :float
    
    add_column :tasks, :raw_estimated_unit_cost, :float
    add_column :tasks, :raw_estimated_fixed_cost, :float
    add_column :tasks, :raw_labor_costs, :float
    add_column :tasks, :raw_material_costs, :float
    add_column :tasks, :total_markup, :float
    
    add_column :unit_cost_estimates, :raw_cost, :float
  end

  def self.down
    rename_column :bids, :raw_cost, :cost
    rename_column :contract_costs, :raw_cost, :cost
    rename_column :fixed_cost_estimates, :raw_cost, :cost
    rename_column :material_costs, :raw_cost, :cost
  
    remove_column :components, :estimated_raw_fixed_cost
    remove_column :components, :estimated_raw_unit_cost
    remove_column :components, :total_markup
    
    remove_column :contracts, :raw_cost
    remove_column :contracts, :raw_invoiced
    remove_column :contracts, :total_markup
    
    remove_column :labor_costs, :raw_cost
    
    remove_column :projects, :estimated_fixed_cost
    remove_column :projects, :estimated_raw_fixed_cost
    remove_column :projects, :estimated_unit_cost
    remove_column :projects, :estimated_raw_unit_cost
    remove_column :projects, :estimated_contract_cost
    remove_column :projects, :estimated_raw_contract_cost
    remove_column :projects, :material_cost
    remove_column :projects, :raw_material_cost
    remove_column :projects, :labor_cost
    remove_column :projects, :raw_labor_cost
    remove_column :projects, :contract_cost
    remove_column :projects, :raw_contract_cost
    remove_column :projects, :projected_cost
    remove_column :projects, :raw_projected_cost
    
    remove_column :tasks, :raw_estimated_unit_cost
    remove_column :tasks, :raw_estimated_fixed_cost
    remove_column :tasks, :raw_labor_costs
    remove_column :tasks, :raw_material_costs
    remove_column :tasks, :total_markup
    
    remove_column :unit_cost_estimates, :raw_cost
  end
end
