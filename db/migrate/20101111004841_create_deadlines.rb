class CreateDeadlines < ActiveRecord::Migration
  def self.up
    create_table :deadlines do |t|
      t.string :name
      t.date :date
      
      t.belongs_to :project
      
      t.timestamps
    end
  end

  def self.down
    drop_table :deadlines
  end
end
