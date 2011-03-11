class TaskDefaultsToFalse < ActiveRecord::Migration
  class Task < ActiveRecord::Base
  end
  
  def self.up
    Task.where(:active => nil).update_all(:active => false)
    change_column_default :tasks, :active, false
  end

  def self.down
  end
end
