class Project < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail
  
  has_many :components, :order => :name, :dependent => :destroy
  has_many :tasks, :order => :name, :dependent => :destroy
  has_many :contracts, :order => :name, :dependent => :destroy
  has_many :deadlines, :order => :date, :dependent => :destroy
  has_many :laborers, :order => :name, :dependent => :destroy
  has_many :suppliers, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => :cascade_add_markup, :before_remove => :cascade_remove_markup
  
  has_and_belongs_to_many :users
  
  validates_presence_of :name
  
  def estimated_fixed_cost(include_markup = true)
    self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_fixed_cost(include_markup))}
  end
  
  def estimated_unit_cost(include_markup = true)
    self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_unit_cost(include_markup))}
  end
  
  def estimated_contract_cost(include_markup = true)
    self.contracts.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_cost(include_markup) )}
  end
  
  def estimated_cost(include_markup = true)
    add_or_nil( self.estimated_contract_cost(include_markup), self.components.roots.inject(nil){|memo,obj| add_or_nil(memo, obj.estimated_cost(include_markup))} )
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
  
  private
  
  def cascade_add_markup(markup)
    # Ancestry doesn't seem to like working with other associations...
    Component.roots.where(:project_id => self.id).all.each {|c| c.markups << markup unless c.markups.include? markup }
    self.tasks.all.each {|t| t.markups << markup unless t.markups.include? markup }
    self.contracts.all.each {|c| c.markups << markup unless c.markups.include? markup }
  end
  
  def cascade_remove_markup(markup)
    # Ancestry doesn't seem to like working with other associations...
    Component.roots.where(:project_id => self.id).all.each {|c| c.markups.delete( markup ) }
    self.tasks.all.each {|t| t.markups.delete( markup ) }
    self.contracts.all.each {|c| c.markups.delete( markup ) }
  end
end
