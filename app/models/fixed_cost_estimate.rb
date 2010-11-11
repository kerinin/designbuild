class FixedCostEstimate < ActiveRecord::Base
  belongs_to :component
  
  has_one :task, :as => :estimate
  
  validates_presence_of :component
end
