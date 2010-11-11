class CreateDerivedQuantities < ActiveRecord::Migration
  def self.up
    create_table :derived_quantities do |t|
      t.string :name
      t.float :multiplier
      
      t.belongs_to :parent_quantity

      t.timestamps
    end
  end

  def self.down
    drop_table :derived_quantities
  end
end
