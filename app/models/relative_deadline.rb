class RelativeDeadline < ActiveRecord::Base
  belongs_to :parent_deadline, :class_name => :deadline
end
