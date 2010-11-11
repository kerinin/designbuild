class CreateMaterialCosts < ActiveRecord::Migration
  def self.up
    create_table :material_costs do |t|
      t.date :date
      t.float :amount
      
      t.belongs_to :task
      
      t.timestamps
    end
  end

  def self.down
    drop_table :material_costs
  end
end
