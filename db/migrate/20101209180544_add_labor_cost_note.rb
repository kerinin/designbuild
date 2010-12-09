class AddLaborCostNote < ActiveRecord::Migration
  def self.up
    add_column :labor_costs, :note, :string
  end

  def self.down
    remove_column :labor_costs, :note
  end
end
