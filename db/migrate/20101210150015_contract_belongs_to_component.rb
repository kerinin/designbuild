class ContractBelongsToComponent < ActiveRecord::Migration
  def self.up
    add_column :contracts, :component_id, :integer
  end

  def self.down
    remove_column :contracts, :component_id
  end
end
