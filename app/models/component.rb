class Component < ActiveRecord::Base
  include AddOrNil

  has_paper_trail :ignore => [:position, :created_at, :updated_at]
  has_ancestry
  
  belongs_to :project, :inverse_of => :components
  
  has_many :quantities, :order => :name, :dependent => :destroy
  has_many :fixed_cost_estimates, :order => :name, :dependent => :destroy
  has_many :unit_cost_estimates, :order => :name, :dependent => :destroy
  has_many :contracts, :order => :name, :dependent => :destroy
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => [:cascade_add_markup, Proc.new{|p,d| p.save!}], :after_remove => [:cascade_remove_markup, Proc.new{|p,d| p.save!}]
  
  has_many :estimated_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :estimated_cost}
    
  has_and_belongs_to_many :tags
  
  #acts_as_list :scope => 'ancestry'
  #acts_as_list :scope => :parent_id
  
  validates_presence_of :project, :name
  
  before_validation :check_project
  after_create :add_parent_markups
  
  before_save :cache_values, :if => :id
  after_create [:cache_values, Proc.new{|c| c.save!}]
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  before_save :create_estimated_cost_points, :if => proc {|i| i.estimated_cost_changed? && ( !i.new_record? || ( !i.estimated_cost.nil? && i.estimated_cost > 0 ) )}
  
  default_scope :order => :position
  
  def tree
    recursion = Proc.new do |component, block|
      collector = [component]
      component.children.each {|child| collector += block.call( child, block ) }
      collector
    end

    recursion.call(self, recursion)
  end
  
  def cost_estimates
    self.fixed_cost_estimates.all + self.unit_cost_estimates.all
  end
  
  def select_label
    (self.ancestors.all + [self]).map {|c| c.name}.join(' > ')
  end
  
  def cache_values
    [self.children, self.fixed_cost_estimates, self.unit_cost_estimates, self.contracts, self.markups].each {|a| a.reload}
    
    self.cache_estimated_costs
  end
    
  def cascade_cache_values
    if self.is_root?
      self.project.reload.save!
    else
      self.parent.reload.save!
    end
    
    Project.find(self.project_id_was).save! if self.project_id_changed? && !self.project_id_was.nil?
  end
  
  
  # Invoicing
  [:labor_cost, :material_cost, :labor_invoiced, :material_invoiced, :invoiced, :labor_retainage, :material_retainage, :retainage, :labor_paid, :material_paid, :paid, :labor_retained, :material_retained, :retained, :labor_outstanding, :material_outstanding, :outstanding].each do |sym|
    self.send(:define_method, sym) do |recursive|
      if recursive
        fixed_cost_estimates = FixedCostEstimate.where('component_id IN (?)', self.subtree_ids)
        unit_cost_estimates = UnitCostEstimate.where('component_id IN (?)', self.subtree_ids)
        contracts = Contract.where('component_id IN (?)', self.subtree_ids)
      else
        fixed_cost_estimates = self.fixed_cost_estimates
        unit_cost_estimates = self.unit_cost_estimates
        contracts = self.contracts
      end
      
      (fixed_cost_estimates.all + unit_cost_estimates.all + contracts.all).inject(0) do |memo, obj|
        if obj.respond_to?(sym)
          memo + obj.send(sym)
        else
          memo
        end
      end
    end
  end

  [:labor_cost_before, :material_cost_before, :labor_invoiced_before, :material_invoiced_before, :invoiced_before, :labor_retainage_before, :material_retainage_before, :retainage_before, :labor_paid_before, :material_paid_before, :paid_before, :labor_retained_before, :material_retained_before, :retained_before, :labor_outstanding_before, :material_outstanding_before, :outstanding_before].each do |sym|
    self.send(:define_method, sym) do |date, recursive|
      date ||= Date::today
      
      if recursive
        fixed_cost_estimates = FixedCostEstimate.where('component_id IN (?)', self.subtree_ids)
        unit_cost_estimates = UnitCostEstimate.where('component_id IN (?)', self.subtree_ids)
        contracts = Contract.where('component_id IN (?)', self.subtree_ids)
      else
        fixed_cost_estimates = self.fixed_cost_estimates
        unit_cost_estimates = self.unit_cost_estimates
        contracts = self.contracts
      end
      
      (fixed_cost_estimates.all + unit_cost_estimates.all + contracts.all).inject(0) do |memo, obj|
        if obj.respond_to?(sym)
          memo + obj.send(sym, date)
        else
          memo
        end
      end
    end
  end
    
  protected
  
  def cache_estimated_costs
    self.estimated_raw_component_fixed_cost = self.fixed_cost_estimates.sum(:raw_cost)
    #self.estimated_raw_subcomponent_fixed_cost = self.children.sum(:estimated_raw_fixed_cost)
    self.estimated_raw_subcomponent_fixed_cost = self.descendants.joins(:fixed_cost_estimates).sum('fixed_cost_estimates.raw_cost').to_f
    #self.estimated_raw_fixed_cost = self.estimated_raw_component_fixed_cost + self.estimated_raw_subcomponent_fixed_cost
    self.estimated_raw_fixed_cost = self.subtree.joins(:fixed_cost_estimates).sum('fixed_cost_estimates.raw_cost').to_f

    self.estimated_raw_component_unit_cost = self.unit_cost_estimates.sum(:raw_cost)
    #self.estimated_raw_subcomponent_unit_cost = self.children.sum(:estimated_raw_unit_cost)
    self.estimated_raw_subcomponent_unit_cost = self.children.joins(:unit_cost_estimates).sum('unit_cost_estimates.raw_cost').to_f
    #self.estimated_raw_unit_cost = self.estimated_raw_component_unit_cost + self.estimated_raw_subcomponent_unit_cost
    self.estimated_raw_unit_cost = self.subtree.joins(:unit_cost_estimates).sum('unit_cost_estimates.raw_cost').to_f

    self.estimated_raw_component_contract_cost = self.contracts.sum(:estimated_raw_cost)
    #self.estimated_raw_subcomponent_contract_cost = self.children.sum(:estimated_raw_contract_cost)
    self.estimated_raw_subcomponent_contract_cost = self.children.joins(:contracts).sum('contracts.estimated_raw_cost').to_f
    #self.estimated_raw_contract_cost = self.estimated_raw_component_contract_cost + self.estimated_raw_subcomponent_contract_cost
    self.estimated_raw_contract_cost = self.subtree.joins(:contracts).sum('contracts.estimated_raw_cost').to_f

    # Leaving this as addition to reduce SQL transactions
    self.estimated_raw_component_cost = self.estimated_raw_component_unit_cost + self.estimated_raw_component_fixed_cost + self.estimated_raw_component_contract_cost 
    self.estimated_raw_subcomponent_cost = self.estimated_raw_subcomponent_unit_cost + self.estimated_raw_subcomponent_fixed_cost + self.estimated_raw_subcomponent_contract_cost    
    self.estimated_raw_cost = self.estimated_raw_unit_cost + self.estimated_raw_fixed_cost + self.estimated_raw_contract_cost
    
    
    self.markings.each {|m| m.set_markup_amount_from!(self) }
    
    
    self.estimated_component_fixed_cost = self.estimated_raw_component_fixed_cost + self.markings.sum(:estimated_fixed_cost_markup_amount)
    #self.estimated_subcomponent_fixed_cost = self.children.sum(:estimated_fixed_cost)
    self.estimated_subcomponent_fixed_cost = self.estimated_raw_subcomponent_fixed_cost + self.children.joins(:markings).sum('markings.estimated_fixed_cost_markup_amount').to_f
    #self.estimated_fixed_cost = self.estimated_component_fixed_cost + self.estimated_subcomponent_fixed_cost
    self.estimated_fixed_cost = self.estimated_raw_fixed_cost + self.subtree.joins(:markings).sum('markings.estimated_fixed_cost_markup_amount').to_f

    self.estimated_component_unit_cost = self.estimated_raw_component_unit_cost + self.markings.sum(:estimated_unit_cost_markup_amount)
    #self.estimated_subcomponent_unit_cost = self.children.sum(:estimated_unit_cost)
    self.estimated_subcomponent_unit_cost = self.estimated_raw_subcomponent_unit_cost + self.children.joins(:markings).sum('markings.estimated_unit_cost_markup_amount').to_f
    #self.estimated_unit_cost = self.estimated_component_unit_cost + self.estimated_subcomponent_unit_cost
    self.estimated_unit_cost = self.estimated_raw_unit_cost + self.subtree.joins(:markings).sum('markings.estimated_unit_cost_markup_amount').to_f

    self.estimated_component_contract_cost = self.estimated_raw_component_contract_cost + self.markings.sum(:estimated_contract_cost_markup_amount)
    #self.estimated_subcomponent_contract_cost = self.children.sum(:estimated_contract_cost)
    self.estimated_subcomponent_contract_cost = self.estimated_raw_subcomponent_contract_cost + self.children.joins(:markings).sum('markings.estimated_contract_cost_markup_amount').to_f
    #self.estimated_contract_cost = self.estimated_component_contract_cost + self.estimated_subcomponent_contract_cost                                    
    self.estimated_contract_cost = self.estimated_raw_contract_cost + self.subtree.joins(:markings).sum('markings.estimated_contract_cost_markup_amount').to_f

    # Leaving this as addition to reduce SQL transactions
    self.estimated_component_cost = self.estimated_component_unit_cost + self.estimated_component_fixed_cost + self.estimated_component_contract_cost
    self.estimated_subcomponent_cost = self.estimated_subcomponent_unit_cost + self.estimated_subcomponent_fixed_cost + self.estimated_subcomponent_contract_cost
    self.estimated_cost = self.estimated_unit_cost + self.estimated_fixed_cost + self.estimated_contract_cost
  end
      
      
  def check_project
    self.project ||= self.parent.project if !self.parent.nil? && !self.parent.project.nil?
  end
  
  def add_parent_markups
    if self.is_root?
      self.project.markups.all.each {|m| self.markups << m unless self.markups.include? m }
    else
      self.parent.markups.all.each {|m| self.markups << m unless self.markups.include? m }
    end
  end
  
  def cascade_add_markup(markup)
    self.children.all.each {|c| c.markups << markup unless c.markups.include? markup }
    self.save
  end
  
  def cascade_remove_markup(markup)
    self.children.all.each {|c| c.markups.delete( markup ) }
    self.save
  end
  
  def create_estimated_cost_points
    p = self.estimated_cost_points.find_or_initialize_by_date(Date::today)
    if p.label.nil?
      p.series = :estimated_cost
      p.value = self.estimated_cost || 0
      p.save!
    end
  end
end
