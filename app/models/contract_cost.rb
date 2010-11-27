class ContractCost < ActiveRecord::Base
  belongs_to :contract
  
  has_paper_trail
  
  validates_presence_of :date, :raw_cost, :contract
  
  validates_numericality_of :raw_cost
  
  after_save :cache_values
  after_destroy :cache_values
  
  def cost
    multiply_or_nil self.raw_cost, (1+(self.contract.total_markup/100))
  end
  
  private
  
  def cache_values
    self.contract.cache_values
  end
end
