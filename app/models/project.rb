class Project < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail
  
  has_many :components, :order => :position, :dependent => :destroy
  has_many :tasks, :order => :name, :dependent => :destroy
  has_many :contracts, :order => :position, :dependent => :destroy
  has_many :deadlines, :order => :date, :dependent => :destroy
  #has_many :laborers, :order => :name, :dependent => :destroy
  has_many :suppliers, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => [:cascade_add_markup, Proc.new{|p,d| p.save}], :after_remove => [:cascade_remove_markup, Proc.new{|p,d| p.save}]
  
  has_many :invoices
  
  has_and_belongs_to_many :users
  
  validates_presence_of :name
  
  before_save :cache_values
  
  def fixed_cost_estimates
    FixedCostEstimate.joins(:component => :project).where(:projects => {:id => self.id})
  end
  
  def unit_cost_estimates
    UnitCostEstimate.joins(:component => :project).where(:projects => {:id => self.id})
  end
  
  def projected_net
    subtract_or_nil self.estimated_cost, self.raw_projected_cost
  end
  
  # estimated_fixed_cost
  
  # estimated_raw_fixed_cost
  
  # estimated_unit_cost
  
  # estimated_raw_unit_cost
  
  def estimated_contract_cost
    self.contract_cost
  end
  
  def estimated_raw_contract_cost
    self.raw_contract_cost
  end
  
  # estimated_contract_cost
  
  # estimated_raw_contract_cost
  
  def estimated_cost
    add_or_nil( self.contract_cost, self.components.roots.all.inject(nil){|memo,obj| add_or_nil(memo, add_or_nil(obj.estimated_unit_cost, obj.estimated_fixed_cost))} )
  end
  
  def estimated_raw_cost
    add_or_nil( self.raw_contract_cost, self.components.roots.all.inject(nil){|memo,obj| add_or_nil(memo, add_or_nil( obj.estimated_raw_unit_cost, obj.estimated_raw_fixed_cost))} )
  end
  
  # labor_cost
  
  # raw_labor_cost
  
  # material_cost
  
  # raw_material_cost
  
  # contract_cost
  
  # raw_contract_cost
  
  def cost
    add_or_nil(self.labor_cost, add_or_nil( self.material_cost, self.contract_invoiced) )
  end
  
  def raw_cost
    add_or_nil(self.raw_labor_cost, add_or_nil( self.raw_material_cost, self.raw_contract_invoiced) )
  end
  
  # projected_cost
  
  # raw_projected_cost

  
  def cache_values
    [self.components, self.contracts, self.tasks].each {|a| a.reload}
    
    self.cache_estimated_fixed_cost
    self.cache_estimated_unit_cost
    self.cache_contract_cost
    self.cache_material_cost
    self.cache_labor_cost
    self.cache_contract_invoiced
    self.cache_projected_cost
  end
  
  
  protected
    
  def cache_estimated_fixed_cost
    self.estimated_fixed_cost = self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_fixed_cost)}
    self.estimated_raw_fixed_cost = self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_raw_fixed_cost)}
  end
  
  def cache_estimated_unit_cost
    self.estimated_unit_cost = self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_unit_cost)}
    self.estimated_raw_unit_cost = self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_raw_unit_cost)}
  end
    
  def cache_contract_cost
    self.contract_cost = self.contracts.inject(nil){|memo,obj| add_or_nil(memo, obj.cost )}
    self.raw_contract_cost = self.contracts.inject(nil){|memo,obj| add_or_nil(memo, obj.raw_cost )}
  end

  def cache_material_cost
    self.material_cost = self.tasks.inject(nil){|memo,obj| add_or_nil(memo, obj.material_cost)}
    self.raw_material_cost = self.tasks.inject(nil){|memo,obj| add_or_nil(memo, obj.raw_material_cost)}
  end
  
  def cache_labor_cost
    self.labor_cost = self.tasks.inject(nil){|memo,obj| add_or_nil(memo, obj.labor_cost)}
    self.raw_labor_cost = self.tasks.inject(nil){|memo,obj| add_or_nil(memo, obj.raw_labor_cost)}
  end
  
  def cache_contract_invoiced
    self.contract_invoiced = self.contracts.inject(nil){|memo,obj| add_or_nil(memo, obj.invoiced)}
    self.raw_contract_invoiced = self.contracts.inject(nil){|memo,obj| add_or_nil(memo, obj.raw_invoiced)}
  end
    
  def cache_projected_cost
    self.projected_cost = add_or_nil( self.contract_cost, self.tasks.inject(nil) {|memo,obj| add_or_nil(memo, obj.projected_cost)} )
    self.raw_projected_cost = add_or_nil( self.raw_contract_cost, self.tasks.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_projected_cost)} )
  end
  
  
  def cascade_add_markup(markup)
    # Ancestry doesn't seem to like working with other associations...
    Component.roots.where(:project_id => self.id).all.each {|c| c.markups << markup unless c.markups.include? markup }
    #self.components.roots.all.each {|c| c.markups << markup unless c.markups.include? markup }
    self.tasks.all.each {|t| t.markups << markup unless t.markups.include? markup }
    self.contracts.all.each {|c| c.markups << markup unless c.markups.include? markup }
    self.save
  end
  
  def cascade_remove_markup(markup)
    # Ancestry doesn't seem to like working with other associations...
    Component.roots.where(:project_id => self.id).all.each {|c| c.markups.delete( markup ) }
    #self.components.roots.all.each {|c| c.markups.delete( markup ) }
    self.tasks.all.each {|t| t.markups.delete( markup ) }
    self.contracts.all.each {|c| c.markups.delete( markup ) }
    self.save
  end
end
