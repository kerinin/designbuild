class Bid < ActiveRecord::Base
  belongs_to :contract
  
  validates_presence_of :contractor, :date, :cost, :contract
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
end
