class RemoveScheduling < ActiveRecord::Migration
  def self.up
    drop_table :deadlines
    drop_table :milestones
    
    remove_column :tasks, :deadline_id 
  end

  def self.down
  end
end
