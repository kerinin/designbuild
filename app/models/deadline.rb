class Deadline < ActiveRecord::Base
  has_many :tasks, :as => :deadline
end
