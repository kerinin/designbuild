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
    
    add_column :deadlines, :date_completed, :date
  end

  def self.down
    remove_column :deadlines, :date_completed, :date
    
    drop_table :milestones
  end
end
