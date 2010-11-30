class CreateMilestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.string :name
      t.date :date
      t.integer :interval
      t.date :date_completed
      
      t.belongs_to :task
      t.belongs_to :project
      t.belongs_to :parent_date, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :milestones
  end
end
