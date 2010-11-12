class Contract < ActiveRecord::Base
  has_many :tasks
  has_many :costs, :class_name => "ContractCost"
  has_many :bids
end
