class Markup < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  has_many :markings, :dependent => :destroy, :inverse_of => :markup, :after_remove => proc {|i,m| puts "markings"}
  
  has_many :projects, :through => :markings, :source => :markupable, :source_type => 'Project', :after_remove => proc {|i,m| puts "markup.projects"}
  has_many :tasks, :through => :markings, :source => :markupable, :source_type => 'Task', :dependent => :destroy
  has_many :components, :through => :markings, :source => :markupable, :source_type => 'Component', :dependent => :destroy
  has_many :fixed_cost_estimates, :through => :markings, :source => :markupable, :source_type => 'FixedCostEstimate', :dependent => :destroy
  has_many :unit_cost_estimates, :through => :markings, :source => :markupable, :source_type => 'UnitCostEstimate', :dependent => :destroy
  has_many :contracts, :through => :markings, :source => :markupable, :source_type => 'Contract', :dependent => :destroy
  has_many :contract_costs, :through => :markings, :source => :markupable, :source_type => 'ContractCost', :dependent => :destroy
  has_many :labor_cost_lines, :through => :markings, :source => :markupable, :source_type => 'LaborCostLine', :dependent => :destroy
  has_many :material_costs, :through => :markings, :source => :markupable, :source_type => 'MaterialCost', :dependent => :destroy
  
  has_many :invoice_markup_lines
  has_many :payment_markup_lines
  
  accepts_nested_attributes_for :markings
  
  validates_presence_of :name, :percent
  
  #before_save {|r| @new_markings = r.markings.map {|m| m.new_record? ? m : nil }.compact }
  #after_save {|r| @new_markings.each {|m| r.cascade_add(m.markupable)} }
  #after_save :cascade_cache_values
  #after_destroy :cascade_cache_values
  
  # Task - estimated / actual?
  # Component - estimated / actual / subcomponents ?
  # Project - estimated / actual / associated ?
  def apply_to(value, method = nil, *args)
    if value.instance_of?( Float ) || value.instance_of?( Integer )
      multiply_or_nil( value, divide_or_nil(self.percent, 100) )
    else
      multiply_or_nil( value.send(method, *args), divide_or_nil(self.percent, 100))
    end
  end
  
  def apply_recursively_to(value, method)
    value.reload
    if value.instance_of?(Project)
      value.applied_markings.where(:markup_id => self.id).sum(method)
    elsif value.instance_of?(Component)
      #Marking.where(:markup_id => self.id).where("component_id in (?)", value.subtree_ids).sum(method)
      value.subtree.joins(:applied_markings).sum(method)
    else
      0
    end
  end
  
  def select_label
    "#{self.name} (#{self.percent}%)"
  end
end
