class Project < ActiveRecord::Base
  include AddOrNil
  
  has_and_belongs_to_many :users
  has_many :components
  has_many :tasks
  has_many :contracts
  has_many :deadlines
  
  def estimated_fixed_cost
    self.components.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_fixed_cost)}
  end
  
  def estimated_unit_cost
    self.components.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_unit_cost)}
  end
  
  def estimated_cost
    self.components.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_cost)}
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
end
