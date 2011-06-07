class AddRequestComment < ActiveRecord::Migration
  def self.up
    add_column :resource_requests, :comment, :string
  end

  def self.down
    remove_column :resource_requests, :comment
  end
end
