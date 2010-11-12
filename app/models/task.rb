class Task < ActiveRecord::Base
  belongs_to :contract
  belongs_to :deadline, :polymorphic => true
  belongs_to :project
  
  has_many :unit_cost_estimates
  has_many :fixed_cost_estimates
  has_many :labor_costs
  has_many :material_costs
  
  validates_presence_of :project

  def cost_estimates
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
  
  def labor_cost
    self.labor_costs.empty? ? nil : self.labor_costs.inject(nil) {|memo, obj| cost = obj.cost; memo.nil? ? obj.cost : memo + (cost.nil? ? 0 : cost)}
  end

  def material_cost
    self.material_costs.empty? ? nil : self.material_costs.inject(nil) {|memo, obj| cost = obj.cost; memo.nil? ? obj.cost : memo + (cost.nil? ? 0 : cost)}
  end  
  
  def cost
    material = labor_cost
    labor = material_cost
    if material.nil? && labor.nil?
      return nil
    else
      return ( material.nil? ? 0 : material ) + ( labor.nil? ? 0 : labor )
    end
  end
end
