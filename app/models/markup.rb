class Markup < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  has_many :markings, :dependent => :destroy
  
  has_many :projects, :through => :markings, :source => :markupable, :source_type => 'Project', :uniq => true, :after_add => :cascade_add, :before_remove => :cascade_remove
  has_many :tasks, :through => :markings, :source => :markupable, :source_type => 'Task', :uniq => true, :after_add => Proc.new{|m,t| t.save}, :after_remove => Proc.new{|m,t| t.save}
  has_many :components, :through => :markings, :source => :markupable, :source_type => 'Component', :uniq => true, :after_add => :cascade_add, :before_remove => :cascade_remove
  has_many :fixed_cost_estimates, :through => :markings, :source => :markupable, :source_type => 'FixedCostEstimate', :uniq => true
  has_many :unit_cost_estimates, :through => :markings, :source => :markupable, :source_type => 'UnitCostEstimate', :uniq => true
  has_many :contracts, :through => :markings, :source => :markupable, :source_type => 'Contract', :uniq => true
  has_many :contract_costs, :through => :markings, :source => :markupable, :source_type => 'ContractCost', :uniq => true
  has_many :labor_cost_lines, :through => :markings, :source => :markupable, :source_type => 'LaborCostLine', :uniq => true
  has_many :material_costs, :through => :markings, :source => :markupable, :source_type => 'MaterialCost', :uniq => true
  
  has_many :invoice_markup_lines
  has_many :payment_markup_lines
  
  accepts_nested_attributes_for :markings
  
  validates_presence_of :name, :percent
  
  before_save {|r| @new_markings = r.markings.map {|m| ( m.new_record? && (m.markupable_type == 'Project' || m.markupable_type == 'Component') ) ? m : nil }.compact }
  after_save {|r| @new_markings.each {|m| r.cascade_add(m.markupable)} }
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
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
      value.subtree.joins(:applied_markings).sum(method)
    else
      0
    end
  end
  
  def cascade_add(obj)
    obj.send :cascade_add_markup, self
  end
  
  def cascade_remove(obj)
    obj.send :cascade_remove_markup, self
  end
  
  def select_label
    "#{self.name} (#{self.percent}%)"
  end

  def cascade_cache_values
    self.markings.all.each {|m| m.save!}
  end
end
