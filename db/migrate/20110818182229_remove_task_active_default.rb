class Task < ActiveRecord::Base
  scope :future, lambda {
    where(:percent_complete => 0).where(:active => false)
  }
end
  
class RemoveTaskActiveDefault < ActiveRecord::Migration
  def self.up
    change_column_default(:tasks, :active, nil)
    
    Task.future.all.each { |t| t.update_attributes(:active => nil) }
  end

  def self.down
    change_column_default(:tasks, :active, false)
  end
end
