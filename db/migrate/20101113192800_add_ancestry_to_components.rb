class AddAncestryToComponents < ActiveRecord::Migration
  def self.up
    add_column :components, :ancestry, :string
    add_index :components, :ancestry
  end

  def self.down
    remove_column :components, :ancestry
    remove_index :components, :ancestry
  end
end
