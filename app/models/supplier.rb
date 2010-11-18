class Supplier < ActiveRecord::Base
  belongs_to :project
  
  has_many :material_costs, :dependent => :destroy
  
  validates_presence_of :name, :project
  
  def purchase_orders
    self.material_costs.where( :material_costs => {:cost => nil} )
  end
  
  def completed_purchases
    self.material_costs.where( "material_costs.cost IS NOT NULL" )
  end
end
