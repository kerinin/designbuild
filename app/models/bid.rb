class Bid < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]

  belongs_to :contract, :inverse_of => :bids
  
  validates_presence_of :contractor, :date, :raw_cost, :contract
  validates_numericality_of :raw_cost
  
  before_save :cache_values
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
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
  
  def cascade_cache_values
    self.contract.reload.save!
  end
  
  protected
  
  def cache_values
    self.cost = self.raw_cost + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_cost)}
  end
end
