class Task < ActiveRecord::Base
  include AddOrNil
  
  belongs_to :contract
  belongs_to :deadline, :polymorphic => true
  belongs_to :project
  
  has_many :unit_cost_estimates, :order => :name
  has_many :fixed_cost_estimates, :order => :name
  has_many :labor_costs, :order => 'date DESC', :dependent => :destroy
  has_many :material_costs, :order => 'date DESC', :dependent => :destroy
  
  validates_presence_of :name, :project

  scope :active, lambda {
    joins(:labor_costs).where(:active => true).where( 'labor_costs.percent_complete < 100').group('tasks.id')
  }
  
  scope :completed, lambda {
    joins(:labor_costs).where( 'labor_costs.percent_complete >= 100').group('tasks.id')
  }
  
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
  
  def purchase_orders
    self.material_costs.where( :material_costs => {:cost => nil} )
  end
  
  def completed_purchases
    self.material_costs.where( "material_costs.cost IS NOT NULL" )
  end
  
  def percent_complete
    return 0 if self.labor_costs.empty?
    self.labor_costs.first.percent_complete
  end
  
  def projected_cost
    return self.cost if self.percent_complete >= 100
    est = self.estimated_cost
    act = self.cost
    return est if act.nil?
    return act if est.nil?
    if act > est
      return act
    else
      return est
    end
  end
end
