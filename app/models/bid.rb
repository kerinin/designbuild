class Bid < ActiveRecord::Base
  belongs_to :contract
  
  validates_presence_of :contract
end
