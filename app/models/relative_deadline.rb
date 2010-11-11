class RelativeDeadline < ActiveRecord::Base
  belongs_to :parent_deadline, :class_name => "Deadline"
  
  validates_presence_of :parent_deadline
end
