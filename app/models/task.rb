class Task < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail
  
  belongs_to :contract
  belongs_to :deadline
  belongs_to :project
  
  has_many :unit_cost_estimates, :order => :name
  has_many :fixed_cost_estimates, :order => :name
  has_many :labor_costs, :order => 'date DESC', :dependent => :destroy
  has_many :material_costs, :order => 'date DESC', :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
  
  validates_presence_of :name, :project

  after_create :add_project_markups

  scope :active, lambda {
    where(:active => true)
  }
  
  scope :completed, lambda {
    joins(:labor_costs) & LaborCost.where( 'percent_complete >= 100' )
  }
  
  scope :future, lambda {
  }
  
  def cost_estimates
    self.unit_cost_estimates + self.fixed_cost_estimates
  end
  
  def costs
    self.labor_costs + self.material_costs
  end
  
  def purchase_orders
    self.material_costs.where( :material_costs => {:cost => nil} )
  end
  
  def completed_purchases
    self.material_costs.where( "material_costs.cost IS NOT NULL" )
  end
  
  
  def estimated_unit_cost
    multiply_or_nil self.estimated_raw_unit_cost, (1+(self.total_markup/100))
  end
  
  # estimated_raw_unit_cost
  
  def estimated_fixed_cost
    multiply_or_nil self.estimated_raw_fixed_cost, (1+(self.total_markup/100))
  end
  
  # estimated_raw_fixed_cost
  
  def estimated_cost
    add_or_nil(estimated_fixed_cost, estimated_unit_cost)
  end
  
  def estimated_raw_cost
    add_or_nil(estimated_raw_fixed_cost, estimated_raw_unit_cost)
  end
  
  def labor_cost
    multiply_or_nil self.raw_labor_cost, (1+(self.total_markup/100))
  end
  
  # raw_labor_cost
  
  def material_cost
    multiply_or_nil self.raw_material_cost, (1+(self.total_markup/100))
  end
  
  # raw_material_cost
  
  def cost
    add_or_nil(labor_cost, material_cost)
  end
  
  def raw_cost
    add_or_nil(raw_labor_cost, raw_material_cost)
  end
  
  # projected_cost
  
  # raw_projected_cost
  
  
  private

  def cache_estimated_unit_cost
    self.estimated_unit_cost = self.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
    self.estimated_raw_unit_cost = self.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  end
  
  def cache_estimated_fixed_cost
    self.estimated_fixed_cost = self.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo,obj.cost)}
    self.estimated_raw_fixed_cost = self.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo,obj.raw_cost)}
  end

  def cache_labor_cost
    self.raw_labor_cost = self.labor_costs.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.labor_cost = multiply_or_nil self.raw_labor_cost, (1 + ( self.total_markup / 100 ))
  end

  def cache_material_cost
    self.raw_material_cost = self.material_costs.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.material_cost = multiply_or_nil self.raw_material_cost, (1 + ( self.total_markup / 100 ))
  end 

  def cache_percent_complete
    self.percent_complete = self.labor_costs.empty? ? 0 : self.labor_costs.first.percent_complete
  end
  
  def cache_projected_cost
    if self.percent_complete >= 100
      self.projected_cost = self.cost
      self.raw_projected_cost = self.raw_cost
      
    est = self.estimated_cost
    act = self.cost
    if act.nil?
      self.projected_cost = self.estimated_cost
      self.raw_projected_cost = self.raw_estimated_cost
    if est.nil?
      self.projected_cost = self.cost
      self.raw_projected_cost = self.raw_cost
    if act > est
      self.projected_cost = self.cost
      self.raw_projected_cost = self.raw_cost
    else
      self.projected_cost = self.estimated_cost
      self.raw_projected_cost = self.raw_estimated_cost
    end
  end
  
  def cache_total_markup
    self.total_markup = self.markups.inject(0) {|memo,obj| memo + obj.percent }
  end
  
        
  def add_project_markups
    self.project.markups.each {|m| self.markups << m unless self.markups.include? m }
  end
end
