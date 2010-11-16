class Deadline < ActiveRecord::Base
  belongs_to :project
  
  has_many :tasks, :as => :deadline
  has_many :relative_deadlines, :class_name => 'RelativeDeadline', :foreign_key => :parent_deadline_id
  
  validates_presence_of :name, :project
end
