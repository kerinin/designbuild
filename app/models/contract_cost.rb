class ContractCost < ActiveRecord::Base
  include MarksUp
  
  belongs_to :contract
  
  has_paper_trail
  
  validates_presence_of :date, :raw_cost, :contract
  
  validates_numericality_of :raw_cost
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  marks_up :raw_cost
  #def cost
  #  multiply_or_nil self.raw_cost, (1+(self.contract.total_markup/100))
  #end

  def cascade_cache_values
    self.contract.save
  end
end
