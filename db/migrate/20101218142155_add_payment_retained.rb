class AddPaymentRetained < ActiveRecord::Migration
  def self.up
    add_column :payments, :retained, :float
  end

  def self.down
    remove_column :payments, :retained
  end
end
