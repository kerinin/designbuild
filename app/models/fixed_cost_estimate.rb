class FixedCostEstimate < ActiveRecord::Base
  belongs_to :component
  belongs_to :task
  
  validates_presence_of :component
end
