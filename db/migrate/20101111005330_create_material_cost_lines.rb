class CreateMaterialCostLines < ActiveRecord::Migration
  def self.up
    create_table :material_cost_lines do |t|
      t.string :name
      t.float :quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :material_cost_lines
  end
end
