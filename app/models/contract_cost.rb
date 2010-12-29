class ContractCost < ActiveRecord::Base
  belongs_to :contract, :inverse_of => :costs
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  validates_presence_of :date, :raw_cost, :contract
  
  validates_numericality_of :raw_cost
  
  before_save :cache_values
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  def markups
    self.contract.markups
  end

  def cascade_cache_values
    self.contract.reload.save!
  end
  
  protected
  
  def cache_values
    self.cost = self.raw_cost + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_cost ) }
  end
end
