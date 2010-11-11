class CreateFixedCostEstimates < ActiveRecord::Migration
  def self.up
    create_table :fixed_cost_estimates do |t|
      t.string :name
      t.float :cost
      
      t.belongs_to :component

      t.timestamps
    end
  end

  def self.down
    drop_table :fixed_cost_estimates
  end
end
