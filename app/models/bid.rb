class Bid < ActiveRecord::Base
  include MarksUp
  
  has_paper_trail

  belongs_to :contract
  
  validates_presence_of :contractor, :date, :raw_cost, :contract
  validates_numericality_of :raw_cost
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  attr_accessor :is_active_bid
  
  def is_active_bid
    self.contract.active_bid == self
  end
  
  def is_active_bid=(bool)
    if bool
      self.contract.active_bid = self
    end
  end
  
  def select_label
    "#{self.contract}"
  end
  
  def total_markup
    self.contract.total_markup unless self.contract.blank?
  end
  
  marks_up :raw_cost
  
  # raw cost
  
  def cascade_cache_values
    self.contract.save!
  end
end
