class CreateUnitCostEstimates < ActiveRecord::Migration
  def self.up
    create_table :unit_cost_estimates do |t|
      t.string :name
      t.float :unit_cost
      
      t.belongs_to :component
      t.belongs_to :quantity
      t.belongs_to :task
      
      t.timestamps
    end
  end

  def self.down
    drop_table :unit_cost_estimates
  end
end
