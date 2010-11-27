class Supplier < ActiveRecord::Base
  has_paper_trail
  
  #belongs_to :project
  
  has_many :material_costs, :dependent => :destroy
  
  validates_presence_of :name #, :project
  
  def purchase_orders
    self.material_costs.where( :material_costs => {:raw_cost => nil} )
  end
  
  def completed_purchases
    self.material_costs.where( "material_costs.raw_cost IS NOT NULL" )
  end
end
