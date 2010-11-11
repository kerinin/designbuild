class CreateLaborers < ActiveRecord::Migration
  def self.up
    create_table :laborers do |t|
      t.string :name
      t.float :pay_rate

      t.timestamps
    end
  end

  def self.down
    drop_table :laborers
  end
end
