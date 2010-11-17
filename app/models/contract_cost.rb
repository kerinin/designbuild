class ContractCost < ActiveRecord::Base
  belongs_to :contract
  
  validates_presence_of :date, :cost, :contract
  
  validates_numericality_of :cost
end
