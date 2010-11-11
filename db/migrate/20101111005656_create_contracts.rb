class CreateContracts < ActiveRecord::Migration
  def self.up
    create_table :contracts do |t|
      t.string :contractor
      t.float :bid

      t.timestamps
    end
  end

  def self.down
    drop_table :contracts
  end
end
