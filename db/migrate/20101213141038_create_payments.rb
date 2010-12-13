class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.date :date
      t.string :state
      t.float :paid
      
      t.belongs_to :project

      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
