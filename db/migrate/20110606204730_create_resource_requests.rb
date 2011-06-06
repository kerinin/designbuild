class CreateResourceRequests < ActiveRecord::Migration
  def self.up
    create_table :resource_requests do |t|
      t.boolean :urgent
      t.date :first_date
      t.date :deadline
      t.float :duration
      t.float :allocated
      t.float :remaining
      
      t.belongs_to :project
      t.belongs_to :task
      t.belongs_to :resource

      t.timestamps
    end
  end

  def self.down
    drop_table :resource_requests
  end
end