class CreateLaborCostLines < ActiveRecord::Migration
  def self.up
    create_table :labor_cost_lines do |t|
      t.float :hours
      
      t.belongs_to :labor_set

      t.timestamps
    end
  end

  def self.down
    drop_table :labor_cost_lines
  end
end
