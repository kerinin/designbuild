class Project < ActiveRecord::Base
  include AddOrNil
  
  has_many :components, :order => :name
  has_many :tasks, :order => :name
  has_many :contracts, :order => :name
  has_many :deadlines, :order => :date
  has_many :laborers, :order => :name
  has_many :suppliers
  
  has_and_belongs_to_many :users
  
  validates_presence_of :name
  
  def estimated_fixed_cost
    self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_fixed_cost)}
  end
  
  def estimated_unit_cost
    self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_unit_cost)}
  end
  
  def estimated_cost
    self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_cost)}
  end
  
  def material_cost
    self.tasks.inject(nil){|memo,obj| add_or_nil(memo, obj.material_cost)}
  end
  
  def labor_cost
    self.tasks.inject(nil){|memo,obj| add_or_nil(memo, obj.labor_cost)}
  end
  
  def contract_cost
    self.contracts.inject(nil){|memo,obj| add_or_nil(memo, obj.cost)}
  end
  
  def cost
    add_or_nil(labor_cost, add_or_nil( material_cost, contract_cost) )
  end
  
  def fixed_cost_estimates
    FixedCostEstimate.joins(:component => :project).where(:projects => {:id => self.id})
  end
  
  def unit_cost_estimates
    UnitCostEstimate.joins(:component => :project).where(:projects => {:id => self.id})
  end
end
