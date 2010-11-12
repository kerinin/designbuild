class CreateRelativeDeadlines < ActiveRecord::Migration
  def self.up
    create_table :relative_deadlines do |t|
      t.string :name
      t.integer :interval
      
      t.belongs_to :parent_deadline
      t.belongs_to :project

      t.timestamps
    end
  end

  def self.down
    drop_table :relative_deadlines
  end
end
