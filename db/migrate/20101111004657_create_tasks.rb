class CreateTasks < ActiveRecord::Migration
  def self.up
    create_table :tasks do |t|
      t.string :name
      
      t.belongs_to :contract
      t.belongs_to :deadline, :polymorphic => true
      t.belongs_to :project

      t.timestamps
    end
  end

  def self.down
    drop_table :tasks
  end
end
