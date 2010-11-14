class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.string :contractor
      t.date :date
      t.float :cost
      
      t.belongs_to :contract

      t.timestamps
    end
  end

  def self.down
    drop_table :bids
  end
end
