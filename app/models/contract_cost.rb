class ContractCost < ActiveRecord::Base
  belongs_to :contract
  
  has_paper_trail
  
  validates_presence_of :date, :cost, :contract
  
  validates_numericality_of :cost
end
