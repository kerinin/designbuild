class LaborCost < ActiveRecord::Base
  belongs_to :task
  
  validates_presence_of :task
end