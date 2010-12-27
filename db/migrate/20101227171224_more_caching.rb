class MoreCaching < ActiveRecord::Migration
  def self.up
    add_column :bids, :cost, :float
    
    add_column :components, :estimated_component_fixed_cost, :float
    add_column :components, :estimated_raw_component_fixed_cost, :float
    add_column :components, :estimated_subcomponent_fixed_cost, :float
    add_column :components, :estimated_raw_subcomponent_fixed_cost, :float
    
    add_column :components, :estimated_component_unit_cost, :float
    add_column :components, :estimated_raw_component_unit_cost, :float
    add_column :components, :estimated_subcomponent_unit_cost, :float
    add_column :components, :estimated_raw_subcomponent_unit_cost, :float
    
    add_column :components, :estimated_component_contract_cost, :float
    add_column :components, :estimated_raw_component_contract_cost, :float
    add_column :components, :estimated_subcomponent_contract_cost, :float
    add_column :components, :estimated_raw_subcomponent_contract_cost, :float
    
    add_column :components, :estimated_component_cost, :float
    add_column :components, :estimated_raw_component_cost, :float
    add_column :components, :estimated_subcomponent_cost, :float
    add_column :components, :estimated_raw_subcomponent_cost, :float
    add_column :components, :estimated_cost, :float
    add_column :components, :estimated_raw_cost, :float
    
    add_column :contracts, :estimated_cost, :float
    add_column :contracts, :cost, :float
    
    add_column :contract_costs, :cost, :float
    
    add_column :fixed_cost_estimates, :cost, :float
    
    add_column :labor_costs, :cost, :float
    
    add_column :material_costs, :cost, :float
    
    add_column :projects, :estimated_cost, :float
    add_column :projects, :estimated_raw_cost, :float
    add_column :projects, :cost, :float
    add_column :projects, :raw_cost, :float
    
    add_column :tasks, :estimated_unit_cost, :float
    add_column :tasks, :estimated_fixed_cost, :float
    add_column :tasks, :estimated_cost, :float
    add_column :tasks, :estimated_raw_cost, :float
    add_column :tasks, :component_estimated_unit_cost, :float
    add_column :tasks, :component_estimated_raw_unit_cost, :float
    add_column :tasks, :component_estimated_cost, :float
    add_column :tasks, :component_estimated_raw_cost, :float
    add_column :tasks, :labor_cost, :float
    add_column :tasks, :material_cost, :float
    add_column :tasks, :cost, :float
    add_column :tasks, :raw_cost, :float
    add_column :tasks, :projected_cost, :float
    add_column :tasks, :raw_projected_cost, :float
    
    add_column :unit_cost_estimates, :cost, :float
  end

  def self.down
    remove_column :bids, :cost
    
    remove_column :components, :estimated_subcomponent_fixed_cost
    remove_column :components, :estimated_raw_subcomponent_fixed_cost
    remove_column :components, :estimated_subcomponent_unit_cost
    remove_column :components, :estimated_raw_subcomponent_unit_cost
    remove_column :components, :estimated_subcomponent_contract_cost
    remove_column :components, :estimated_raw_subcomponent_contract_cost
    remove_column :components, :estimated_subcomponent_cost
    remove_column :components, :estimated_raw_subcomponent_cost
    remove_column :components, :estimated_cost
    remove_column :components, :estimated_raw_cost
    
    remove_column :contracts, :estimated_cost
    remove_column :contracts, :cost
    
    remove_column :contract_costs, :cost
    
    remove_column :fixed_cost_estimates, :cost
    
    remove_column :labor_costs, :cost
    
    remove_column :material_costs, :cost
    
    remove_column :projects, :estimated_cost
    remove_column :projects, :estimated_raw_cost
    remove_column :projects, :cost
    remove_column :projects, :raw_cost
    
    remove_column :tasks, :estimated_unit_cost
    remove_column :tasks, :estimated_fixed_cost
    remove_column :tasks, :estimated_cost
    remove_column :tasks, :estimated_raw_cost
    remove_column :tasks, :component_estimated_unit_cost
    remove_column :tasks, :component_estimated_raw_unit_cost
    remove_column :tasks, :component_estimated_cost
    remove_column :tasks, :component_estimated_raw_cost
    remove_column :tasks, :labor_cost
    remove_column :tasks, :material_cost
    remove_column :tasks, :cost
    remove_column :tasks, :raw_cost
    remove_column :tasks, :projected_cost
    remove_column :tasks, :raw_projected_cost
    
    remove_column :unit_cost_estimates, :cost
  end
end
