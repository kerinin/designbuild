class RefactorDeadlines < ActiveRecord::Migration
  class Deadline < ActiveRecord::Base
  end
  
  class RelativeDeadline < ActiveRecord::Base
  end
  
  def self.up
    change_table :deadlines do |t|
      t.integer :interval
      
      t.belongs_to :parent_deadline
    end
    
    Deadline.reset_column_information
    RelativeDeadline.all.each {|rd| Deadline.create(rd.attributes) }
    
    drop_table :relative_deadlines
  end

  def self.down
    create_table :relative_deadlines do |t|
      t.string :name
      t.integer :interval
      
      t.belongs_to :parent_deadline

      t.timestamps
    end
    
    RelativeDeadline.reset_column_information
    Deadline.where(:date => nil).each {|d| RelativeDeadline.create(d.attributes) }
    
    change_table :deadlines do |t|
      t.remove :interval, :parent_deadline_id
    end
  end
end
