class Task < ActiveRecord::Base
  belongs_to :contract
  belongs_to :deadline, :polymorphic => true
  belongs_to :project
  
  has_many :unit_cost_estimates
  has_many :fixed_cost_estimates
  has_many :labor_costs
  has_many :material_costs
  
  def estimates
    self.unit_cost_estimates + self.fixed_cost_estimates
  end
  
  def costs
    self.labor_costs + self.material_costs
  end
end
