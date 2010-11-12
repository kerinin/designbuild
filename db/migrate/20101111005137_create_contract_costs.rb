class CreateContractCosts < ActiveRecord::Migration
  def self.up
    create_table :contract_costs do |t|
      t.date :date
      t.float :cost
      
      t.belongs_to :contract

      t.timestamps
    end
  end

  def self.down
    drop_table :contract_costs
  end
end
