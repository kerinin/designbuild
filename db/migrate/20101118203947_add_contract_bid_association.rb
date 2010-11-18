class AddContractBidAssociation < ActiveRecord::Migration
  def self.up
    add_column :contracts, :bid_id, :integer
  end

  def self.down
    remove_column :contracts, :bid_id
  end
end
