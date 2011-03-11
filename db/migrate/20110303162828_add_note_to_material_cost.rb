class AddNoteToMaterialCost < ActiveRecord::Migration
  def self.up
    add_column :material_costs, :note, :string
  end

  def self.down
    remove_column :material_costs, :note
  end
end
