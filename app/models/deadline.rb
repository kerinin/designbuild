class Deadline < ActiveRecord::Base
  belongs_to :project
  
  has_many :tasks, :as => :deadline
end
