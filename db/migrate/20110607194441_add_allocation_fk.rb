class AddAllocationFk < ActiveRecord::Migration
  def self.up
    add_column :resource_allocations, :resource_id, :integer
  end

  def self.down
    remove_column :resource_allocations, :resoruce_id
  end
end
