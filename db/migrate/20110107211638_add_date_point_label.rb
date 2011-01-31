class AddDatePointLabel < ActiveRecord::Migration
  def self.up
    add_column :date_points, :label, :string
    add_index :date_points, :label
  end

  def self.down
    remove_index :date_points, :label
    remove_column :date_points, :label
  end
end
