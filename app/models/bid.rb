class Bid < ActiveRecord::Base
  has_paper_trail

  belongs_to :contract
  
  validates_presence_of :contractor, :date, :raw_cost, :contract
  validates_numericality_of :cost
  
  attr_accessor :is_active_bid
  
  def is_active_bid
    self.contract.active_bid == self
  end
  
  def is_active_bid=(bool)
    if bool
      self.contract.active_bid = self
    end
  end
  
  def cost
    self.raw_cost * ( 1 + ( self.contract.total_markup / 100 ) )
  end
end
