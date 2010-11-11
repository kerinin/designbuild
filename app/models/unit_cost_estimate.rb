class UnitCostEstimate < ActiveRecord::Base
  belongs_to :quantity
  
  has_one :component, :through => :quantity
  
  validates_presence_of :quantity
end
