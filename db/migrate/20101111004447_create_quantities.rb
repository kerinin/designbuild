class CreateQuantities < ActiveRecord::Migration
  def self.up
    create_table :quantities do |t|
      t.string :name
      t.float :value
      t.string :unit
      t.float :drop
      
      t.belongs_to :component

      t.timestamps
    end
  end

  def self.down
    drop_table :quantities
  end
end
