class CreateMarkups < ActiveRecord::Migration
  def self.up
    create_table :markups do |t|
      t.string :name
      t.float :percent
      
      t.belongs_to :parent, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :markups
  end
end
