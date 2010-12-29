class MarkupAmountOnMarking < ActiveRecord::Migration
  def self.up
    add_column :markings, :project_id, :integer
    
    add_column :markings, :estimated_unit_cost_markup_amount, :float, {:default => 0, :null => false}
    add_column :markings, :estimated_fixed_cost_markup_amount, :float, {:default => 0, :null => false}
    add_column :markings, :estimated_contract_cost_markup_amount, :float, {:default => 0, :null => false}
    add_column :markings, :estimated_cost_markup_amount, :float, {:default => 0, :null => false}
    
    add_column :markings, :labor_cost_markup_amount, :float, {:default => 0, :null => false}
    add_column :markings, :material_cost_markup_amount, :float, {:default => 0, :null => false}
    add_column :markings, :cost_markup_amount, :float, {:default => 0, :null => false}
  end

  def self.down
    remove_column :markings, :project_id
    
    remove_column :markings, :estimated_unit_cost_markup_amount
    remove_column :markings, :estimated_fixed_cost_markup_amount
    remove_column :markings, :estimated_contract_cost_markup_amount
    remove_column :markings, :estimated_cost_markup_amount
    
    remove_column :markings, :labor_cost_markup_amount
    remove_column :markings, :material_cost_markup_amount
    remove_column :markings, :cost_markup_amount
  end
end
