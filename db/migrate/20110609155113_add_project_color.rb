class AddProjectColor < ActiveRecord::Migration
  def self.up
    add_column :projects, :color, :integer
  end

  def self.down
    remove_column :project, :color
  end
end
