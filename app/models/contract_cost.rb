class ContractCost < ActiveRecord::Base
  belongs_to :contract
  
  has_paper_trail
  
  validates_presence_of :date, :raw_cost, :contract
  
  validates_numericality_of :raw_cost
  
  def cost
    multiply_or_nil self.raw_cost, (1+(self.contract.total_markup/100))
  end
end
