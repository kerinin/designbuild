class Task < ActiveRecord::Base
  belongs_to :contract
  belongs_to :deadline, :polymorphic => true
  belongs_to :project
  
  has_many :unit_cost_estimates
  has_many :fixed_cost_estimates
  has_many :labor_costs
  has_many :material_costs
  
  validates_presence_of :project

  def estimates
    self.unit_cost_estimates + self.fixed_cost_estimates
  end
  
  def costs
    self.labor_costs + self.material_costs
  end
  
  def estimated_unit_cost
    self.unit_cost_estimates.empty? ? nil : self.unit_cost_estimates.inject(0) {|memo, obj| memo + obj.cost}
  end
  
  def estimated_fixed_cost
    self.fixed_cost_estimates.empty? ? nil : self.fixed_cost_estimates.inject(0) {|memo, obj| memo + obj.cost}
  end
  
  def estimated_cost
    fixed = estimated_fixed_cost
    unit = estimated_unit_cost
    if fixed.nil? && unit.nil?
      return nil
    else
      return ( fixed.nil? ? 0 : fixed ) + ( unit.nil? ? 0 : unit )
    end
  end
end
