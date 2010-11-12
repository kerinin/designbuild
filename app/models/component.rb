class Component < ActiveRecord::Base
  belongs_to :parent, :class_name => "Component"
  belongs_to :project
  
  has_many :subcomponents, :class_name => "Component", :foreign_key => :parent_id
  has_many :quantities
  has_many :derived_quantities
  has_many :fixed_cost_estimates
  has_many :unit_cost_estimates
  
  has_and_belongs_to_many :tags
  
  validates_presence_of :project
  
  before_validation :check_project
  
  def all_quantities
    self.quantities.all + self.derived_quantities.all
  end
  
  def cost_estimates
    self.fixed_cost_estimates.all + self.unit_cost_estimates.all
  end
  
  def estimated_component_fixed_cost
    self.fixed_cost_estimates.empty? ? nil : self.fixed_cost_estimates.inject(0) {|memo, obj| memo + obj.cost}
  end
  
  def estimated_fixed_cost
    if self.subcomponents.empty?
      return self.estimated_component_fixed_cost
    else
      sub = self.subcomponents.inject(nil) {|memo, obj| cost = obj.estimated_fixed_cost; memo.nil? ? obj.estimated_fixed_cost : memo + (cost.nil? ? 0 : cost ) }
      return sub.nil? ? self.estimated_component_fixed_cost : sub + self.estimated_component_fixed_cost
    end
  end
  
  def estimated_component_unit_cost
    self.unit_cost_estimates.empty? ? nil : self.unit_cost_estimates.inject(0) {|memo, obj| memo + (obj.unit_cost * obj.quantity.value)}
  end
  
  def estimated_unit_cost
    if self.subcomponents.empty?
      return self.estimated_component_unit_cost
    else
      sub = self.subcomponents.inject(nil) {|memo, obj| cost = obj.estimated_unit_cost; memo.nil? ? obj.estimated_unit_cost : memo + (cost.nil? ? 0 : cost ) }
      return sub.nil? ? self.estimated_component_unit_cost : sub + self.estimated_component_unit_cost
    end
  end
  
  def estimated_component_cost
    fixed = estimated_component_fixed_cost
    unit = estimated_component_unit_cost
    if fixed.nil? && unit.nil?
      return nil
    else
      return ( fixed.nil? ? 0 : fixed ) + ( unit.nil? ? 0 : unit )
    end
  end
  
  def estimated_cost
    if self.subcomponents.empty?
      return self.estimated_component_cost
    else
      sub = self.subcomponents.inject(nil) {|memo, obj| cost = obj.estimated_cost; memo.nil? ? obj.estimated_cost : memo + (cost.nil? ? 0 : cost) }
      return sub.nil? ? self.estimated_component_cost : sub + self.estimated_component_cost
    end
  end
  
  private
  
  def check_project
    self.project = self.parent.project if !self.project && !self.parent.nil? && !self.parent.project.nil?
  end
end
