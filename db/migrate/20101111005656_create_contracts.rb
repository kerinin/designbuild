class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.string :name
      t.float :bid

      t.belongs_to :project
      
      t.timestamps
    end
  end

  def self.down
    drop_table :contracts
  end
end
