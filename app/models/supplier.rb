class Supplier < ActiveRecord::Base
  has_many :material_costs
  
  validates_presence_of :name
  
  def purchase_orders
    self.material_costs.where( :material_costs => {:cost => nil} )
  end
  
  def completed_purchases
    self.material_costs.where( "material_costs.cost IS NOT NULL" )
  end
end
