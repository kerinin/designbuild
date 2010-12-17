class ContractCost < ActiveRecord::Base
  include MarksUp
  
  belongs_to :contract
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  validates_presence_of :date, :raw_cost, :contract
  
  validates_numericality_of :raw_cost
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  def total_markup
    self.contract.total_markup unless self.contract.blank?
  end
  
  marks_up :raw_cost

  def cascade_cache_values
    self.contract.save!
  end
end
