class RemoveContractBidField < ActiveRecord::Migration
  def self.up
    remove_column :contracts, :bid
  end

  def self.down
    add_column :contracts, :bid, :float
  end
end
