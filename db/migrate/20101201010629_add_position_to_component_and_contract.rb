class AddPositionToComponentAndContract < ActiveRecord::Migration
  def self.up
    add_column :components, :position, :integer
    add_column :contracts, :position, :integer
  end

  def self.down
    remove_column :components, :position
    remove_column :contracts, :position
  end
end
