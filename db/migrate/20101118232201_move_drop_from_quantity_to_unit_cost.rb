class MoveDropFromQuantityToUnitCost < ActiveRecord::Migration
  def self.up
    remove_column :quantities, :drop
    add_column :unit_cost_estimates, :drop, :float
  end

  def self.down
    add_column :quantities, :drop, :float
    remove_column :unit_cost_estimates, :drop
  end
end
