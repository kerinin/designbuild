class AddProjectShortName < ActiveRecord::Migration
  def self.up
    add_column :projects, :short, :string
  end

  def self.down
    remove_column :projects, :short
  end
end
