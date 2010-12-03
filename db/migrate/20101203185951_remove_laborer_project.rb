class RemoveLaborerProject < ActiveRecord::Migration
  def self.up
    remove_column :laborers, :project_id
  end

  def self.down
    add_column :laborers, :project_id, :integer
  end
end
