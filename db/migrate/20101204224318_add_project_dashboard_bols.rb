class AddProjectDashboardBols < ActiveRecord::Migration
  def self.up
    add_column :projects, :show_planning, :boolean, :default => true
    add_column :projects, :show_construction, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :show_planning
    remove_column :projects, :show_construction
  end
end
