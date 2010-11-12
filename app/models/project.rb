class Project < ActiveRecord::Base
  has_and_belongs_to_many :users
  has_many :components
  has_many :tasks
  has_many :contracts
  has_many :deadlines
  
  def estimated_fixed_cost
  end
  
  def estimated_unit_cost
  end
  
  def estimated_cost
  end
  
  def material_cost
  end
  
  def labor_cost
  end
  
  def contract_cost
  end
  
  def cost
  end
end
