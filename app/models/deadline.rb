class Deadline < ActiveRecord::Base
  belongs_to :project
  
  has_many :tasks, :as => :deadline
  
  validates_presence_of :project
end
