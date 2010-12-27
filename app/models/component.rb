class Component < ActiveRecord::Base
  include AddOrNil
  include MarksUp
  
  has_paper_trail :ignore => [:position, :created_at, :updated_at]
  has_ancestry
  
  belongs_to :project, :inverse_of => :components
  
  has_many :quantities, :order => :name, :dependent => :destroy
  has_many :fixed_cost_estimates, :order => :name, :dependent => :destroy
  has_many :unit_cost_estimates, :order => :name, :dependent => :destroy
  has_many :contracts, :order => :name
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => [:cascade_add_markup, Proc.new{|p,d| p.save}], :after_remove => [:cascade_remove_markup, Proc.new{|p,d| p.save}]
  
  has_and_belongs_to_many :tags
  
  #acts_as_list :scope => 'ancestry'
  #acts_as_list :scope => :parent_id
  
  validates_presence_of :project, :name
  
  before_validation :check_project
  after_create :add_parent_markups
  
  before_save :cache_values, :if => :id
  after_create :cache_values
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  default_scope :order => :position
  
  def cost_estimates
    self.fixed_cost_estimates.all + self.unit_cost_estimates.all
  end
  
  def select_label
    (self.ancestors.all + [self]).map {|c| c.name}.join(' > ')
  end
  
  
  # Fixed Costs
  # estimated_fixed_cost
  
  # estimated_raw_fixed_cost
  
  # This could also happen on the fixed cost and be requested - fc.cost
  # I like it better here because it doesn't require looking up another object's markup
  #marks_up :estimated_raw_component_fixed_cost
  
  #def estimated_raw_component_fixed_cost
  #  self.fixed_cost_estimates.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  #end
  
  # This is happening remotely because the markup is component-specific
  def estimated_subcomponent_fixed_cost
    self.children.all.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_fixed_cost)}
  end
  
  def estimated_raw_subcomponent_fixed_cost
    self.children.all.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_raw_fixed_cost)}
  end
  
  # Unit Costs
  # estimated_unit_cost
  
  # estimated_raw_unit_cost
  #marks_up :estimated_raw_component_unit_cost
  
  #def estimated_raw_component_unit_cost
  #  self.unit_cost_estimates.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
  #end
  
  def estimated_subcomponent_unit_cost
    self.children.all.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_unit_cost)}
  end
  
  def estimated_raw_subcomponent_unit_cost
    self.children.all.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_raw_unit_cost)}
  end
  
  # Contract Costs
  #estimated_contract_cost
  
  #estimated_raw_contract_cost
  
  #def estimated_component_contract_cost
  #  self.contracts.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.estimated_cost)}
  #end
  
  #def estimated_raw_component_contract_cost
  #  self.contracts.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.estimated_raw_cost)}
  #end
  
  def estimated_subcomponent_contract_cost
    self.children.all.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_contract_cost)}
  end
  
  def estimated_raw_subcomponent_contract_cost
    self.children.all.inject(nil) {|memo,obj| add_or_nil(memo,obj.estimated_raw_contract_cost)}
  end
  
  
  # Total Cost
  #def estimated_component_cost
  #  add_or_nil( add_or_nil( self.estimated_component_unit_cost, self.estimated_component_fixed_cost ), self.estimated_component_contract_cost )
  #end
  
  #def estimated_raw_component_cost
  #  add_or_nil( add_or_nil( self.estimated_raw_component_unit_cost, self.estimated_raw_component_fixed_cost ), self.estimated_raw_component_contract_cost )
  #end
  
  #def estimated_cost
  #  add_or_nil( add_or_nil( self.estimated_unit_cost, self.estimated_fixed_cost ), self.estimated_contract_cost )
  #end
  
  #def estimated_raw_cost
  #  add_or_nil( add_or_nil( self.estimated_raw_unit_cost, self.estimated_raw_fixed_cost ), self.estimated_raw_contract_cost )
  #end
  
  
  def cache_values
    [self.children, self.fixed_cost_estimates, self.unit_cost_estimates, self.contracts, self.markups].each {|a| a.reload}
    
    self.cache_estimated_fixed_cost
    self.cache_estimated_unit_cost
    self.cache_estimated_contract_cost
    self.cache_estimated_cost
    self.cache_total_markup
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
    self.send(:define_method, sym) do
      (self.fixed_cost_estimates + self.unit_cost_estimates + self.contracts).inject(0) do |memo, obj|
        if obj.respond_to?(sym)
          memo + obj.send(sym)
        else
          memo
        end
      end
    end
  end

  [:labor_cost_before, :material_cost_before, :labor_invoiced_before, :material_invoiced_before, :invoiced_before, :labor_retainage_before, :material_retainage_before, :retainage_before, :labor_paid_before, :material_paid_before, :paid_before, :labor_retained_before, :material_retained_before, :retained_before, :labor_outstanding_before, :material_outstanding_before, :outstanding_before].each do |sym|
    self.send(:define_method, sym) do |date|
      date ||= Date::today
      (self.fixed_cost_estimates + self.unit_cost_estimates + self.contracts).inject(0) do |memo, obj|
        if obj.respond_to?(sym)
          memo + obj.send(sym, date)
        else
          memo
        end
      end
    end
  end
    
  protected
  
  def cache_estimated_fixed_cost
    self.estimated_raw_component_fixed_cost = self.fixed_cost_estimates.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.estimated_component_fixed_cost = mark_up self.estimated_raw_component_fixed_cost
    self.estimated_fixed_cost = add_or_nil( self.estimated_component_fixed_cost, self.estimated_subcomponent_fixed_cost )
    self.estimated_raw_fixed_cost = add_or_nil( self.estimated_raw_component_fixed_cost, self.estimated_raw_subcomponent_fixed_cost )
  end

  def cache_estimated_unit_cost
    self.estimated_raw_component_unit_cost = self.unit_cost_estimates.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.estimated_component_unit_cost = mark_up self.estimated_raw_component_unit_cost
    self.estimated_unit_cost = add_or_nil( self.estimated_component_unit_cost, self.estimated_subcomponent_unit_cost )
    self.estimated_raw_unit_cost = add_or_nil( self.estimated_raw_component_unit_cost, self.estimated_raw_subcomponent_unit_cost )
  end

  def cache_estimated_contract_cost
    self.estimated_component_contract_cost = self.contracts.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.estimated_cost)}
    self.estimated_raw_component_contract_cost = self.contracts.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.estimated_raw_cost)}
    self.estimated_contract_cost = add_or_nil( self.estimated_component_contract_cost, self.estimated_subcomponent_contract_cost )
    self.estimated_raw_contract_cost = add_or_nil( self.estimated_raw_component_contract_cost, self.estimated_raw_subcomponent_contract_cost )
  end
  
  def cache_estimated_cost
    self.estimated_component_cost = add_or_nil( add_or_nil( self.estimated_component_unit_cost, self.estimated_component_fixed_cost ), self.estimated_component_contract_cost )
    self.estimated_raw_component_cost = add_or_nil( add_or_nil( self.estimated_raw_component_unit_cost, self.estimated_raw_component_fixed_cost ), self.estimated_raw_component_contract_cost )
    self.estimated_cost = add_or_nil( add_or_nil( self.estimated_unit_cost, self.estimated_fixed_cost ), self.estimated_contract_cost )
    self.estimated_raw_cost = add_or_nil( add_or_nil( self.estimated_raw_unit_cost, self.estimated_raw_fixed_cost ), self.estimated_raw_contract_cost )
  end
  
  def cache_total_markup
    self.total_markup = self.markups.all.inject(0) {|memo,obj| memo + obj.percent }
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
    self.contracts.all.each {|c| c.markups << markup unless c.markups.include? markup }
    self.children.all.each {|c| c.markups << markup unless c.markups.include? markup }
    self.save
  end
  
  def cascade_remove_markup(markup)
    self.contracts.all.each {|c| c.makrups.delete( markup ) }
    self.children.all.each {|c| c.markups.delete( markup ) }
    self.save
  end
end
