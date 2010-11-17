class Bid < ActiveRecord::Base
  belongs_to :contract
  
  validates_presence_of :contractor, :date, :cost, :contract
end
