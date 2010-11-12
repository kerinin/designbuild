class Contract < ActiveRecord::Base
  belongs_to :project
  
  has_many :tasks
  has_many :costs, :class_name => "ContractCost"
  has_many :bids
  
  validates_presence_of :project
end
