class AddTaskPercentComplete < ActiveRecord::Migration
  def self.up
    add_column :tasks, :percent_complete, :float, :null => false, :default => 0
  end

  def self.down
    remove_column :tasks, :percent_complete
  end
end
