class CreateDatePoints < ActiveRecord::Migration
  def self.up
    create_table :date_points do |t|
      t.string :series
      t.date :date
      t.float :value
      
      t.belongs_to :source, :polymorhpic => true

      t.timestamps
    end
    
    create_index :date_points, :value
    create_index :date_points, :date
    create_index :date_points, :series
    create_index :date_points, :source_id
    create_index :date_points, :source_type
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
