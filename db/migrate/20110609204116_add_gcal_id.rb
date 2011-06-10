class AddGcalId < ActiveRecord::Migration
  def self.up
    add_column :resources, :calendar_id, :string
    add_column :resource_allocations, :event_id, :string
  end

  def self.down
    remove_column :resources, :calendar_id
    remove_column :resource_allocations, :event_id
  end
end
