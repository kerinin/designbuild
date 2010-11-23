class Component < ActiveRecord::Base
  include AddOrNil
  
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
  
  def cost_estimates
    self.fixed_cost_estimates.all + self.unit_cost_estimates.all
  end
    
  def estimated_component_fixed_cost(include_markup = true)
    multiply_or_nil ( include_markup ? (1 + ( self.total_markup / 100 )) : 1), self.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end

  def estimated_subcomponent_fixed_cost(include_markup)
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_fixed_cost(include_markup))}
  end
    
  def estimated_fixed_cost(include_markup = true)
    add_or_nil( self.estimated_component_fixed_cost(include_markup), self.estimated_subcomponent_fixed_cost(include_markup) )
  end
  
  def estimated_component_unit_cost(include_markup = true)
    multiply_or_nil (include_markup ? (1 + (self.total_markup / 100)) : 1 ), self.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil(memo, obj.cost)}
  end

  def estimated_subcomponent_unit_cost(include_markup = true)
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_unit_cost(include_markup))}
  end
    
  def estimated_unit_cost(include_markup = true)
    add_or_nil( self.estimated_component_unit_cost(include_markup), self.estimated_subcomponent_unit_cost(include_markup) )
  end
  
  def estimated_component_cost(include_markup = true)
    add_or_nil( estimated_component_fixed_cost(include_markup), estimated_component_unit_cost(include_markup) )
  end

  def estimated_subcomponent_cost(include_markup = true)
    self.children.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_cost(include_markup))}
  end
    
  def estimated_cost(include_markup = true)
    add_or_nil( self.estimated_component_cost(include_markup), self.estimated_subcomponent_cost(include_markup) )
  end
  
  def select_label
    (self.ancestors + [self]).map {|c| c.name}.join(' > ')
  end
  
  def total_markup
    self.markups.inject(0) {|memo,obj| memo + obj.percent }
  end
  
  private
  
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
  end
  
  def cascade_remove_markup(markup)
    self.children.all.each {|c| c.markups.delete( markup ) }
  end
end
