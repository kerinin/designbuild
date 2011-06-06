class CreateResourceAllocations < ActiveRecord::Migration
  def self.up
    create_table :resource_allocations do |t|
      t.datetime :start_date
      t.float :duration
      
      t.belongs_to :resource_request

      t.timestamps
    end
  end

  def self.down
    drop_table :resource_allocations
  end
end
