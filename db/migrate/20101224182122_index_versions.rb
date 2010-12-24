class IndexVersions < ActiveRecord::Migration
  def self.up
    add_index :versions, :created_at
  end

  def self.down
    remove_index :versions, :created_at
  end
end
