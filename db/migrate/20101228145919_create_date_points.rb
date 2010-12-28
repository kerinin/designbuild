class CreateDatePoints < ActiveRecord::Migration
  def self.up
    create_table :date_points do |t|
      t.string :series
      t.date :date
      t.float :value
      
      t.belongs_to :source, :polymorphic => true

      t.timestamps
    end
    
    add_index :date_points, :value
    add_index :date_points, :date
    add_index :date_points, :series
    add_index :date_points, :source_id
    add_index :date_points, :source_type
  end

  def self.down
    remove_index :date_points, :value
    remove_index :date_points, :date
    remove_index :date_points, :series
    remove_index :date_points, :source_id
    remove_index :date_points, :source_type
    
    drop_table :date_points
  end
end
