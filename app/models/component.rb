class Component < ActiveRecord::Base
  include AddOrNil
  include MarkupValues
  
  has_paper_trail
  has_ancestry
  
  belongs_to :project
  
  has_many :quantities, :order => :name, :dependent => :destroy
  has_many :fixed_cost_estimates, :order => :name, :dependent => :destroy
  has_many :unit_cost_estimates, :order => :name, :dependent => :destroy
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => :cascade_add_markup, :before_remove => :cascade_remove_markup
  
  has_and_belongs_to_many :tags
  
  validates_presence_of :project, :name
  
  before_validation :check_project
  after_create :add_parent_markups
  after_save :cache_values
  after_create :add_project_markups
  
  def cost_estimates
    self.fixed_cost_estimates.all + self.unit_cost_estimates.all
  end
  
  def select_label
    (self.ancestors + [self]).map {|c| c.name}.join(' > ')
  end
  
  
  # Fixed Costs
  # estimated_fixed_cost
  
  # estimated_raw_fixed_cost
  
  # This could also happen on the fixed cost and be requested - fc.cost
  # I like it better here because it doesn't require looking up another object's markup
  def estimated_component_fixed_cost
    multiply_or_nil self.estimated_raw_component_fixed_cost, (1+(self.total_markup / 100))
  end
  
  def estimated_raw_component_fixed_cost
    self.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  end
  
  # This is happening remotely because the markup is component-specific
  def estimated_subcomponent_fixed_cost
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_fixed_cost)}
  end
  
  def estimated_raw_subcomponent_fixed_cost
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_raw_fixed_cost)}
  end
  
  # Unit Costs
  # estimated_unit_cost
  
  # estimated_raw_unit_cost
  
  def estimated_component_unit_cost
    multiply_or_nil self.estimated_raw_component_unit_cost, (1+(self.total_markup / 100))
  end
  
  def estimated_raw_component_unit_cost
    self.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  end
  
  def estimated_subcomponent_unit_cost
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_unit_cost)}
  end
  
  def estimated_raw_subcomponent_unit_cost
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_raw_unit_cost)}
  end
  
  # Total Cost
  def estimated_cost
    add_or_nil( self.estimated_unit_cost, self.estimated_fixed_cost )
  end
  
  def estimated_raw_cost
    add_or_nil( self.estimated_raw_unit_cost, self.estimated_raw_fixed_cost )
  end
  
  private
  
  def cache_values
    self.cache_estimated_raw_fixed_cost
    self.cache_estimated_raw_unit_cost
    self.cache_total_markup
    
    self.project.cache_values
  end
  
  def cache_estimated_raw_fixed_cost
    self.estimated_fixed_cost = add_or_nil( self.estimated_component_fixed_cost, self.estimated_subcomponent_fixed_cost )
    self.estimated_raw_fixed_cost = add_or_nil( self.estimated_raw_component_fixed_cost, self.estimated_raw_subcomponent_fixed_cost )
  end

  def cache_estimated_raw_unit_cost
    self.estimated_unit_cost = add_or_nil( self.estimated_component_unit_cost, self.estimated_subcomponent_unit_cost )
    self.estimated_raw_unit_cost = add_or_nil( self.estimated_raw_component_unit_cost, self.estimated_raw_subcomponent_unit_cost )
  end

  def cache_total_markup
    self.total_markup = self.markups.inject(0) {|memo,obj| memo + obj.percent }
  end
      
      
  def check_project
    self.project ||= self.parent.project if !self.parent.nil? && !self.parent.project.nil?
  end
  
  def add_parent_markups
    if self.is_root?
      self.project.markups.each {|m| self.markups << m unless self.markups.include? m }
    else
      self.parent.markups.each {|m| self.markups << m unless self.markups.include? m }
    end
  end
  
  def cascade_add_markup(markup)
    self.children.all.each {|c| c.markups << markup unless c.markups.include? markup }
    self.cache_values
  end
  
  def cascade_remove_markup(markup)
    self.children.all.each {|c| c.markups.delete( markup ) }
    self.cache_values
  end
end
