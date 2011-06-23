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
  has_many :markups, :through => :markings, :uniq => true, :after_add => :cascade_add_markup, :after_remove => :cascade_remove_markup
  has_many :applied_markings, :class_name => 'Marking'
  
  has_many :estimated_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :estimated_cost}, :dependent => :destroy
  
  has_many :invoice_lines
  has_many :payment_lines
  has_many :material_costs
  has_many :labor_costs
  
  has_and_belongs_to_many :tags
  
  validates_presence_of :project, :name
  
  before_validation :check_project
  
  #before_save :create_estimated_cost_points, :if => proc {|i| i.estimated_cost_changed? && ( !i.new_record? || ( !i.estimated_cost.nil? && i.estimated_cost > 0 ) )}
  
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
  
  
  # Invoicing

  [:invoiced, :retainage, :labor_invoiced, :labor_retainage, :material_invoiced, :material_retainage].each do |sym|
    self.send(:define_method, sym) do
      #self.invoice_lines.inject(0) {|memo,obj| memo + obj.send(sym)}
      self.invoice_lines.sum(sym)
    end
  end

  [:invoiced_before, :retainage_before, :labor_invoiced_before, :labor_retainage_before, :material_invoiced_before, :material_retainage_before].each do |sym|
    self.send(:define_method, sym) do |date|
      date ||= Date::today
      #self.invoice_lines.includes(:invoice).where('invoices.date <= ?', date).inject(0) {|memo,obj| memo + obj.send(sym.to_s.split('_before').first)}
      self.invoice_lines.includes(:invoice).where('invoices.date <= ?', date).sum(sym.to_s.split('_before'))
    end
  end
  
  [:paid, :retained, :labor_paid, :labor_retained, :material_paid, :material_retained].each do |sym|
    self.send(:define_method, sym) do
      #self.payment_lines.inject(0) {|memo,obj| memo + obj.send(sym)}
      self.payment_lines.sum(sym)
    end
  end
  
  [:paid_before, :retained_before, :labor_paid_before, :labor_retained_before, :material_paid_before, :material_retained_before].each do |sym|
    self.send(:define_method, sym) do |date|
      date ||= Date::today
      #self.payment_lines.includes(:payment).where('payments.date <= ?', date).inject(0) {|memo,obj| memo + obj.send(sym.to_s.split('_before').first)}
      self.payment_lines.includes(:payment).where('payments.date <= ?', date).sum(sym.to_s.split('_before'))
    end
  end

  def labor_percent
    # portion of task's cost's to date which are for labor
    unless !self.respond_to?(:task) || self.task.nil? || self.task.blank? || self.task.cost.nil?
      pct = multiply_or_nil 100, divide_or_nil( self.task.labor_cost, self.task.cost )
      pct ||= 0
    end
    
    # default to 50%
    pct ||= 50
  end

  def material_percent
    # to ensure these always sum to 100
    100 - self.labor_percent
  end   
  
  [:labor_percent, :material_percent].each do |sym|
    self.send(:define_method, "#{sym}_float") do
      divide_or_nil self.send(sym), 100
    end
  end
  
  def labor_outstanding
    self.labor_invoiced - self.labor_paid
  end
  
  def labor_outstanding_before(date = Date::today)
    self.labor_invoiced_before(date) - self.labor_paid_before(date)
  end
  
  def material_outstanding
    self.material_invoiced - self.material_paid
  end
  
  def material_outstanding_before(date = Date::today)
    self.material_invoiced_before(date) - self.material_paid_before(date)
  end
  
  def outstanding
    self.labor_outstanding + self.material_outstanding
  end
  
  def outstanding_before(date = Date::today)
    self.labor_outstanding_before(date) + self.material_outstanding_before(date)
  end
  
  def labor_cost
    raw_labor_cost + self.labor_costs.joins(:line_items => :markings).sum('markings.cost_markup_amount').to_f
  end
  
  def labor_cost_before( date = Date::today )
    raw_labor_cost_before(date) + self.labor_costs.joins(:line_items => :markings).where( "labor_costs.date <= ?", date ).sum('markings.cost_markup_amount').to_f
  end
  
  def material_cost
    raw_material_cost + self.material_costs.joins(:markings).sum('markings.cost_markup_amount').to_f
  end
  
  def material_cost_before( date = Date::today )
    raw_material_cost_before(date) + self.material_costs.joins(:markings).where( "date <= ?", date ).sum('markings.cost_markup_amount').to_f
  end
  
  def contract_cost
    raw_contract_cost + self.contracts.joins(:costs => :markings).sum('markings.cost_markup_amount').to_f
  end
  
  def contract_cost_before( date = Date::today )
    raw_contract_cost_before(date) + self.contracts.joins(:costs => :markings).where( "contract_costs.date <= ?", date).sum( 'markings.cost_markup_amount' ).to_f
  end
  
  def cost
    self.labor_cost + self.material_cost + self.contract_cost
  end
  
  def cost_before( date = Date::today )
    self.labor_cost_before(date) + self.material_cost_before(date) + self.contract_cost_before(date)
  end


  # Aggregators
  
  def estimated_component_fixed_cost
    estimated_raw_component_fixed_cost + self.fixed_cost_estimates.joins(:markings).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_component_unit_cost
    estimated_raw_component_unit_cost + self.unit_cost_estimates.joins(:markings).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_component_contract_cost
    estimated_raw_component_contract_cost + self.contracts.joins(:markings).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_component_cost
    estimated_component_fixed_cost + estimated_component_unit_cost + estimated_component_contract_cost
  end
  
  def estimated_raw_component_fixed_cost
    self.fixed_cost_estimates.sum(:raw_cost).to_f
  end
  def estimated_raw_component_unit_cost
    self.unit_cost_estimates.sum(:raw_cost).to_f
  end
  def estimated_raw_component_contract_cost
    self.contracts.sum(:estimated_raw_cost).to_f
  end
  def estimated_raw_component_cost
    estimated_raw_component_fixed_cost + estimated_raw_component_unit_cost + estimated_raw_component_contract_cost
  end
    
  def estimated_subcomponent_fixed_cost
    estimated_raw_subcomponent_fixed_cost + self.descendants.joins(:fixed_cost_estimates => :markings ).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_subcomponent_unit_cost
    estimated_raw_subcomponent_unit_cost + self.descendants.joins(:unit_cost_estimates => :markings ).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_subcomponent_contract_cost
    estimated_raw_subcomponent_contract_cost + self.descendants.joins(:contracts => :markings ).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_subcomponent_cost
    estimated_subcomponent_fixed_cost + estimated_subcomponent_unit_cost + estimated_subcomponent_contract_cost
  end
  
  def estimated_raw_subcomponent_fixed_cost
    self.descendants.joins(:fixed_cost_estimates).sum('fixed_cost_estimates.raw_cost').to_f
  end
  def estimated_raw_subcomponent_unit_cost
    self.descendants.joins(:unit_cost_estimates).sum('unit_cost_estimates.raw_cost').to_f
  end
  def estimated_raw_subcomponent_contract_cost
    self.descendants.joins(:contracts).sum('contracts.estimated_raw_cost').to_f
  end
  def estimated_subcomponent_cost
    estimated_raw_subcomponent_fixed_cost + estimated_raw_subcomponent_unit_cost + estimated_raw_subcomponent_contract_cost
  end
    
  def estimated_fixed_cost
    estimated_raw_fixed_cost + self.subtree.joins(:fixed_cost_estimates => :markings ).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_unit_cost
    estimated_raw_unit_cost + self.subtree.joins(:unit_cost_estimates => :markings ).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_contract_cost
    estimated_raw_contract_cost + self.subtree.joins(:contracts => :markings ).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_cost
    estimated_fixed_cost + estimated_unit_cost + estimated_contract_cost
  end
  
  def estimated_raw_fixed_cost
    self.subtree.joins(:fixed_cost_estimates).sum('fixed_cost_estimates.raw_cost').to_f
  end
  def estimated_raw_unit_cost
    self.subtree.joins(:unit_cost_estimates).sum('unit_cost_estimates.raw_cost').to_f
  end
  def estimated_raw_contract_cost
    self.subtree.joins(:contracts).sum('contracts.estimated_raw_cost').to_f
  end
  def estimated_raw_cost
    estimated_raw_fixed_cost + estimated_raw_unit_cost + estimated_raw_contract_cost
  end
  

  protected
      
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
    # Add the markup to everything in the component subtree
    
    markup.fixed_cost_estimates << self.fixed_cost_estimates
    markup.unit_cost_estimates << self.unit_cost_estimates
    markup.contracts << self.contracts
    markup.contract_costs << ContractCost.where('contract_id in (?)', self.contract_ids)
    markup.labor_cost_lines << LaborCostLine.where('labor_set_id in (?)', self.labor_cost_ids)
    markup.material_costs << self.material_costs
    
    markup.components << self.descendants
  end
  
  def cascade_remove_markup(markup)
    # remove the markup from everything in the component subtree
    Marking.where('component_id in (?)', self.subtree_ids).delete_all
    #self.subtree.applied_markings.delete_all
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
