class CostDefaultZero < ActiveRecord::Migration
  def self.up
    change_column :bids, "raw_cost", :float, { :default => 0, :null => false }
    change_column :bids, "cost", :float, { :default => 0, :null => false }

    change_column :components, "estimated_fixed_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_unit_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_fixed_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_unit_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_contract_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_contract_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_component_fixed_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_component_fixed_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_subcomponent_fixed_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_subcomponent_fixed_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_component_unit_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_component_unit_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_subcomponent_unit_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_subcomponent_unit_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_component_contract_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_component_contract_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_subcomponent_contract_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_subcomponent_contract_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_component_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_component_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_subcomponent_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_subcomponent_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_cost", :float, { :default => 0, :null => false }
    change_column :components, "estimated_raw_cost", :float, { :default => 0, :null => false }

    change_column :contract_costs, "raw_cost", :float, { :default => 0, :null => false }
    change_column :contract_costs, "cost", :float, { :default => 0, :null => false }

    change_column :contracts, "estimated_raw_cost", :float, { :default => 0, :null => false }
    change_column :contracts, "raw_cost", :float, { :default => 0, :null => false }
    change_column :contracts, "estimated_cost", :float, { :default => 0, :null => false }
    change_column :contracts, "cost", :float, { :default => 0, :null => false }

    change_column :fixed_cost_estimates, "raw_cost", :float, { :default => 0, :null => false }
    change_column :fixed_cost_estimates, "cost", :float, { :default => 0, :null => false }

    change_column :labor_cost_lines, "raw_cost", :float, { :default => 0, :null => false }
    change_column :labor_cost_lines, "laborer_pay", :float, { :default => 0, :null => false }

    change_column :labor_costs, "raw_cost", :float, { :default => 0, :null => false }
    change_column :labor_costs, "cost", :float, { :default => 0, :null => false }

    change_column :projects, "estimated_fixed_cost", :float, { :default => 0, :null => false }
    change_column :projects, "estimated_raw_fixed_cost", :float, { :default => 0, :null => false }
    change_column :projects, "estimated_unit_cost", :float, { :default => 0, :null => false }
    change_column :projects, "estimated_raw_unit_cost", :float, { :default => 0, :null => false }
    change_column :projects, "estimated_contract_cost", :float, { :default => 0, :null => false }
    change_column :projects, "estimated_raw_contract_cost", :float, { :default => 0, :null => false }
    change_column :projects, "material_cost", :float, { :default => 0, :null => false }
    change_column :projects, "raw_material_cost", :float, { :default => 0, :null => false }
    change_column :projects, "labor_cost", :float, { :default => 0, :null => false }
    change_column :projects, "raw_labor_cost", :float, { :default => 0, :null => false }
    change_column :projects, "contract_cost", :float, { :default => 0, :null => false }
    change_column :projects, "raw_contract_cost", :float, { :default => 0, :null => false }
    change_column :projects, "projected_cost", :float, { :default => 0, :null => false }
    change_column :projects, "raw_projected_cost", :float, { :default => 0, :null => false }
    change_column :projects, "estimated_cost", :float, { :default => 0, :null => false }
    change_column :projects, "estimated_raw_cost", :float, { :default => 0, :null => false }
    change_column :projects, "cost", :float, { :default => 0, :null => false }
    change_column :projects, "raw_cost", :float, { :default => 0, :null => false }

    change_column :tasks, "estimated_raw_unit_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "estimated_raw_fixed_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "raw_labor_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "raw_material_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "estimated_unit_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "estimated_fixed_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "estimated_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "estimated_raw_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "component_estimated_unit_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "component_estimated_raw_unit_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "component_estimated_fixed_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "component_estimated_raw_fixed_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "component_estimated_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "component_estimated_raw_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "labor_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "material_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "cost", :float, { :default => 0, :null => false }
    change_column :tasks, "raw_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "projected_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "raw_projected_cost", :float, { :default => 0, :null => false }

    change_column :tasks, "raw_cost", :float, { :default => 0, :null => false }
    change_column :tasks, "cost", :float, { :default => 0, :null => false }
  end

  def self.down
    change_column :bids, "raw_cost", :float, { :default => nil, :null => true }
    change_column :bids, "cost", :float, { :default => nil, :null => true }

    change_column :components, "estimated_fixed_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_unit_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_fixed_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_unit_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_contract_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_contract_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_component_fixed_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_component_fixed_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_subcomponent_fixed_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_subcomponent_fixed_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_component_unit_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_component_unit_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_subcomponent_unit_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_subcomponent_unit_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_component_contract_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_component_contract_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_subcomponent_contract_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_subcomponent_contract_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_component_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_component_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_subcomponent_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_subcomponent_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_cost", :float, { :default => nil, :null => true }
    change_column :components, "estimated_raw_cost", :float, { :default => nil, :null => true }

    change_column :contract_costs, "raw_cost", :float, { :default => nil, :null => true }
    change_column :contract_costs, "cost", :float, { :default => nil, :null => true }

    change_column :contracts, "estimated_raw_cost", :float, { :default => nil, :null => true }
    change_column :contracts, "raw_cost", :float, { :default => nil, :null => true }
    change_column :contracts, "estimated_cost", :float, { :default => nil, :null => true }
    change_column :contracts, "cost", :float, { :default => nil, :null => true }

    change_column :fixed_cost_estimates, "raw_cost", :float, { :default => nil, :null => true }
    change_column :fixed_cost_estimates, "cost", :float, { :default => nil, :null => true }

    change_column :labor_cost_lines, "raw_cost", :float, { :default => nil, :null => true }
    change_column :labor_cost_lines, "laborer_pay", :float, { :default => nil, :null => true }

    change_column :labor_costs, "raw_cost", :float, { :default => nil, :null => true }
    change_column :labor_costs, "cost", :float, { :default => nil, :null => true }

    change_column :projects, "estimated_fixed_cost", :float, { :default => nil, :null => true }
    change_column :projects, "estimated_raw_fixed_cost", :float, { :default => nil, :null => true }
    change_column :projects, "estimated_unit_cost", :float, { :default => nil, :null => true }
    change_column :projects, "estimated_raw_unit_cost", :float, { :default => nil, :null => true }
    change_column :projects, "estimated_contract_cost", :float, { :default => nil, :null => true }
    change_column :projects, "estimated_raw_contract_cost", :float, { :default => nil, :null => true }
    change_column :projects, "material_cost", :float, { :default => nil, :null => true }
    change_column :projects, "raw_material_cost", :float, { :default => nil, :null => true }
    change_column :projects, "labor_cost", :float, { :default => nil, :null => true }
    change_column :projects, "raw_labor_cost", :float, { :default => nil, :null => true }
    change_column :projects, "contract_cost", :float, { :default => nil, :null => true }
    change_column :projects, "raw_contract_cost", :float, { :default => nil, :null => true }
    change_column :projects, "projected_cost", :float, { :default => nil, :null => true }
    change_column :projects, "raw_projected_cost", :float, { :default => nil, :null => true }
    change_column :projects, "estimated_cost", :float, { :default => nil, :null => true }
    change_column :projects, "estimated_raw_cost", :float, { :default => nil, :null => true }
    change_column :projects, "cost", :float, { :default => nil, :null => true }
    change_column :projects, "raw_cost", :float, { :default => nil, :null => true }

    change_column :tasks, "estimated_raw_unit_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "estimated_raw_fixed_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "raw_labor_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "raw_material_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "estimated_unit_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "estimated_fixed_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "estimated_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "estimated_raw_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "component_estimated_unit_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "component_estimated_raw_unit_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "component_estimated_fixed_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "component_estimated_raw_fixed_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "component_estimated_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "component_estimated_raw_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "labor_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "material_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "cost", :float, { :default => nil, :null => true }
    change_column :tasks, "raw_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "projected_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "raw_projected_cost", :float, { :default => nil, :null => true }

    change_column :tasks, "raw_cost", :float, { :default => nil, :null => true }
    change_column :tasks, "cost", :float, { :default => nil, :null => true }
  end
end
