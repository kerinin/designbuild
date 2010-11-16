class Task < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :contract
  belongs_to :deadline, :polymorphic => true
  belongs_to :project
  
  has_many :unit_cost_estimates, :order => :name
  has_many :fixed_cost_estimates, :order => :name
  has_many :labor_costs, :order => 'date DESC'
  has_many :material_costs, :order => 'date DESC'
  
  validates_presence_of :project

  def cost_estimates
    self.unit_cost_estimates + self.fixed_cost_estimates
  end
  
  def costs
    self.labor_costs + self.material_costs
  end
  
  def estimated_unit_cost
    self.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end
  
  def estimated_fixed_cost
    self.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo,obj.cost)}
  end
  
  def estimated_cost
    add_or_nil(estimated_fixed_cost, estimated_unit_cost)
  end
  
  def labor_cost
    self.labor_costs.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end

  def material_cost
    self.material_costs.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end  
  
  def cost
    add_or_nil(labor_cost, material_cost)
  end
end
