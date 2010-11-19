class Component < ActiveRecord::Base
  include AddOrNil
  
  has_ancestry
  
  belongs_to :project
  
  has_many :quantities, :order => :name, :dependent => :destroy
  has_many :fixed_cost_estimates, :order => :name, :dependent => :destroy
  has_many :unit_cost_estimates, :order => :name, :dependent => :destroy
  has_many :markups, :as => :parent, :order => :name, :dependent => :destroy
  
  has_and_belongs_to_many :tags
  
  validates_presence_of :project, :name
  
  before_validation :check_project
  
  def cost_estimates
    self.fixed_cost_estimates.all + self.unit_cost_estimates.all
  end
  
  def estimated_component_fixed_cost
    self.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end

  def estimated_subcomponent_fixed_cost
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_fixed_cost)}
  end
    
  def estimated_fixed_cost
    add_or_nil( self.estimated_component_fixed_cost, self.estimated_subcomponent_fixed_cost )
  end
  
  def estimated_component_unit_cost
    self.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end

  def estimated_subcomponent_unit_cost
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_unit_cost)}
  end
    
  def estimated_unit_cost
    add_or_nil( self.estimated_component_unit_cost, self.estimated_subcomponent_unit_cost )
  end
  
  def estimated_component_cost
    add_or_nil( estimated_component_fixed_cost, estimated_component_unit_cost )
  end

  def estimated_subcomponent_cost
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_cost)}
  end
    
  def estimated_cost
    add_or_nil( self.estimated_component_cost, self.estimated_subcomponent_cost )
  end
  
  def select_label
    (self.ancestors + [self]).map {|c| c.name}.join(' > ')
  end
  
  private
  
  def check_project
    self.project ||= self.parent.project if !self.parent.nil? && !self.parent.project.nil?
  end
end
