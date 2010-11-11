class CreateBids < ActiveRecord::Migration
  def self.up
    create_table :bids do |t|
      t.date :date
      t.float :amount
      
      t.belongs_to :contract

      t.timestamps
    end
  end

  def self.down
    drop_table :bids
  end
end
