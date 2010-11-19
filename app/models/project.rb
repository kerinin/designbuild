class Project < ActiveRecord::Base
  include AddOrNil
  
  has_many :components, :order => :name, :dependent => :destroy
  has_many :tasks, :order => :name, :dependent => :destroy
  has_many :contracts, :order => :name, :dependent => :destroy
  has_many :deadlines, :order => :date, :dependent => :destroy
  has_many :laborers, :order => :name, :dependent => :destroy
  has_many :suppliers, :dependent => :destroy
  has_many :default_markups, :class_name => 'Markup', :as => :parent, :order => :name, :dependent => :destroy
  
  has_and_belongs_to_many :users
  
  validates_presence_of :name
  
  def estimated_fixed_cost
    self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_fixed_cost)}
  end
  
  def estimated_unit_cost
    self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_unit_cost)}
  end
  
  def estimated_contract_cost
    self.contracts.inject(nil){|memo,obj| add_or_nil(memo, obj.bid)}
  end
  
  def estimated_cost
    add_or_nil( self.estimated_contract_cost, self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_cost)} )
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
  
  def projected_cost
    add_or_nil( self.contract_cost, self.tasks.inject(nil) {|memo,obj| add_or_nil(memo, obj.projected_cost)} )
  end
end
