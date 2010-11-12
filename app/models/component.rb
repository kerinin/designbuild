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
  
  def estimated_fixed_cost
    self.fixed_cost_estimates.empty? ? nil : self.fixed_cost_estimates.inject(0) {|memo, obj| memo + obj.cost}
  end
  
  def estimated_unit_cost
    self.unit_cost_estimates.empty? ? nil : self.unit_cost_estimates.inject(0) {|memo, obj| memo + (obj.unit_cost * obj.quantity.value)}
  end
  
  def estimated_cost
    fixed = estimated_fixed_cost
    unit = estimated_unit_cost
    if fixed.nil? && unit.nil?
      return nil
    else
      return ( fixed.nil? ? 0 : fixed ) + ( unit.nil? ? 0 : unit )
    end
  end
  
  private
  
  def check_project
    self.project = self.parent.project if !self.project && !self.parent.nil? && !self.parent.project.nil?
  end
end
