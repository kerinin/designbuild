class RelativeDeadline < ActiveRecord::Base
  belongs_to :parent_deadline, :class_name => "Deadline"
  
  has_many :tasks, :as => :deadline
  
  validates_presence_of :name, :interval, :parent_deadline
  validates_numericality_of :interval
  
  def date
    parent_deadline.date + self.interval
  end
end
