class CreateMarkings < ActiveRecord::Migration
  def self.up
    create_table :markings do |t|
      t.belongs_to :markupable, :polymorphic => true
      t.belongs_to :markup

      t.timestamps
    end
    
    remove_column :markups, :parent_id
    remove_column :markups, :parent_type
  end

  def self.down
    drop_table :markings
    
    add_column :markups, :parent_id, :integer
    add_column :markups, :parent_type, :string
  end
end
