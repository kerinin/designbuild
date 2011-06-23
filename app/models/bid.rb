class Bid < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]

  belongs_to :contract #, :inverse_of => :bids
  
  validates_presence_of :contractor, :date, :raw_cost, :contract
  validates_numericality_of :raw_cost
  
  after_save :update_contract
  
  attr_accessor :is_active_bid
  
  def markups
    self.contract.markups
  end
  
  def is_active_bid?
    self.is_active_bid
  end
  
  def is_active_bid
    self.contract.active_bid == self
  end
  
  def is_active_bid=(bool)
    if bool
      self.contract.active_bid = self
      self.contract.save!
    end
  end
  
  def select_label
    "#{self.contractor} (#{self.date.to_s :short}: $#{self.raw_cost.to_i})"
  end
  
  protected
  
  def update_contract
    self.contract.save!
  end
end
