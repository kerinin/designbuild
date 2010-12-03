class AddLaborerPayRate < ActiveRecord::Migration
  def self.up
    add_column :laborers, :pay_rate, :float
  end

  def self.down
    remove_column :laborers, :pay_rate
  end
end
