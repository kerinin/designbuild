class MaterialCostLineToString < ActiveRecord::Migration
  def self.up
    change_column :material_cost_lines, :quantity, :string
  end

  def self.down
    change_column :material_cost_lines, :quantity, :float
  end
end
