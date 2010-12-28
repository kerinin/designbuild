class ContractCost < ActiveRecord::Base
  include MarksUp
  
  belongs_to :contract, :inverse_of => :costs
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  validates_presence_of :date, :raw_cost, :contract
  
  validates_numericality_of :raw_cost
  
  before_save :cache_values
  
  after_save :cascade_cache_values, :create_points
  after_destroy :cascade_cache_values
  
  def total_markup
    self.contract.total_markup unless self.contract.blank?
  end

  def cascade_cache_values
    self.contract.save!
  end
  
  protected
  
  def cache_values
    self.cost = mark_up :raw_cost
  end
  
  def create_points
    self.contract.project.cost_to_date_points.find_or_create_by_date(self.date).update_attributes(:value => self.contract.project.labor_cost_before(self.date) + self.contract.project.material_cost_before(self.date))
    self.contract.cost_to_date_points.find_or_create_by_date(self.date).update_attributes(:value => self.contract.cost_before(self.date) )
  end
end
