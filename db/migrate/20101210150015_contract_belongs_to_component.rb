class ContractBelongsToComponent < ActiveRecord::Migration
  def self.up
    add_column :contracts, :component_id, :integer
    add_column :components, :estimated_contract_cost, :float
    add_column :components, :estimated_raw_contract_cost, :float
  end

  def self.down
    remove_column :contracts, :component_id
    remove_column :components, :estimated_contract_cost
    remove_column :components, :estimated_raw_contract_cost
  end
end
