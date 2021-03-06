class CreateLaborCosts < ActiveRecord::Migration
  def self.up
    create_table :labor_costs do |t|
      t.date :date
      t.float :percent_complete
      
      t.belongs_to :task

      t.timestamps
    end
  end

  def self.down
    drop_table :labor_costs
  end
end
