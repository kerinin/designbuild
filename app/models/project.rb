class Project < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  has_many :components, :order => "components.position", :dependent => :destroy
  has_many :tasks, :order => "tasks.name", :dependent => :destroy
  has_many :contracts, :order => "contracts.position", :dependent => :destroy
  has_many :deadlines, :order => "deadlines.date", :dependent => :destroy
  has_many :suppliers, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :dependent => :destroy, :after_remove => :cascade_remove
  has_many :applied_markings, :class_name => 'Marking'
  
  has_many :invoices, :order => 'invoices.date DESC'
  has_many :payments, :order => 'payments.date DESC'
  has_many :labor_costs
  has_many :material_costs
  
  has_many :estimated_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :estimated_cost}, :dependent => :destroy
  has_many :projected_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :projected_cost}, :dependent => :destroy
  has_many :cost_to_date_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :cost_to_date}, :dependent => :destroy
  
  has_many :resource_requests
  
  has_and_belongs_to_many :users
  
  validates_presence_of :name
  validates_numericality_of :labor_percent_retainage, :material_percent_retainage
  
  #before_save :create_estimated_cost_points, :if => proc {|i| i.estimated_cost_changed? && ( !i.new_record? || ( !i.estimated_cost.nil? && i.estimated_cost > 0 ) )}
  #before_save :create_projected_cost_points, :if => proc {|i| i.projected_cost_changed? && ( !i.new_record? || ( !i.projected_cost.nil? && i.projected_cost > 0 ) )}
  
  def active_markups
    Markup.all.map {|m| m.apply_recursively_to(self, :estimated_cost_markup_amount) > 0 ? m : nil}.compact
  end
  
  def component_tree
    self.components.roots.inject([]) {|memo,obj| memo + obj.tree}
  end
  
  def fixed_bid?
    self.fixed_bid
  end
  
  def cost_plus?
    !self.fixed_bid
  end
  
  def fixed_cost_estimates
    FixedCostEstimate.joins(:component => :project).where(:projects => {:id => self.id})
  end
  
  def unit_cost_estimates
    UnitCostEstimate.joins(:component => :project).where(:projects => {:id => self.id})
  end
  
  def projected_net
    subtract_or_nil self.estimated_cost, self.raw_projected_cost
  end
  
  
  # Invoicing
  [:labor_percent_retainage, :material_percent_retainage, :contract_percent_retainage].each do |sym|
    self.send(:define_method, "#{sym.to_s}_float") do
      divide_or_nil( self.send(sym), 100 ) || 0
    end
  end
  
  #:labor_cost, :material_cost, 
  [:labor_outstanding, :material_outstanding, :outstanding].each do |sym|
    self.send(:define_method, sym) do
      (self.components + self.contracts.without_component).inject(0) do |memo, obj|
        if obj.respond_to?(sym)
          memo + obj.send(sym)
        else
          memo
        end
      end
    end
  end
  
  # Invoice aggregators
  [:labor_invoiced, :material_invoiced, :invoiced, :labor_retainage, :material_retainage, :retainage].each do |sym|
    self.send(:define_method, sym) do
      self.invoices.includes(:lines).sum("invoice_lines.#{sym}").to_f + self.invoices.includes(:markup_lines).sum("invoice_markup_lines.#{sym}").to_f
    end
  end

  # Payment aggregators
  [:labor_paid, :material_paid, :paid, :labor_retained, :material_retained, :retained].each do |sym|
    self.send(:define_method, sym) do
      self.payments.includes(:lines).sum("payment_lines.#{sym}").to_f + self.payments.includes(:markup_lines).sum("payment_markup_lines.#{sym}").to_f
    end
  end
  
  # Cost aggregators NOTE: Not verified!!!
  [:labor_cost_before, :material_cost_before, :labor_outstanding_before, :material_outstanding_before, :outstanding_before].each do |sym|
    self.send(:define_method, sym) do |date|
      (self.fixed_cost_estimates + self.unit_cost_estimates + self.contracts).inject(0) do |memo, obj|
        if obj.respond_to?(sym)
          memo + obj.send(sym, date)
        else
          memo
        end
      end      
    end
  end
  
  # Invoice aggregators
  [:labor_invoiced_before, :material_invoiced_before, :invoiced_before, :labor_retainage_before, :material_retainage_before, :retainage_before].each do |sym|
    self.send(:define_method, sym) do |date|
      date ||= Date::today
      /(.+)_before/ =~ sym.to_s
      method = $1
      self.invoices.includes(:lines).where("date <= ?", date).sum("invoice_lines.#{method}").to_f + self.invoices.includes(:markup_lines).where("date <= ?", date).sum("invoice_markup_lines.#{method}").to_f
    end
  end

  # Payment aggregators
  [:labor_paid_before, :material_paid_before, :paid_before, :labor_retained_before, :material_retained_before, :retained_before].each do |sym|
    self.send(:define_method, sym) do |date|
      date ||= Date::today
      /(.+)_before/ =~ sym.to_s
      method = $1
      self.payments.includes(:lines).where("date <= ?", date).sum("payment_lines.#{method}").to_f + self.payments.includes(:markup_lines).where("date <= ?", date).sum("payment_markup_lines.#{method}").to_f
    end
  end

  # Invoice markup aggregators
  [:markup_labor_invoiced_before, :markup_material_invoiced_before, :markup_invoiced_before, :markup_labor_retainage_before, :markup_material_retainage_before, :markup_retainage_before].each do |sym|
    self.send(:define_method, sym) do |markup, date|
      date ||= Date::today
      /markup_(.+)_before/ =~ sym.to_s
      method = $1
      self.invoices.includes(:markup_lines).where("date <= ?", date).where('invoice_markup_lines.markup_id = ?', markup.id).sum("invoice_markup_lines.#{method}").to_f 
    end
  end

  # Payment markup aggregators
  [:markup_labor_paid_before, :markup_material_paid_before, :markup_paid_before, :markup_labor_retained_before, :markup_material_retained_before, :markup_retained_before].each do |sym|
    self.send(:define_method, sym) do |markup, date|
      date ||= Date::today
      /markup_(.+)_before/ =~ sym.to_s
      method = $1
      self.payments.includes(:markup_lines).where("date <= ?", date).where('payment_markup_lines.markup_id = ?', markup.id).sum("payment_markup_lines.#{method}").to_f 
    end
  end
  
  def create_labeled_point(label, series = :estimated_cost, *args)
    self.send( "create_#{series}_points", *args )
    self.components.each {|c| c.send("create_#{series}_points", *args)}
    self.tasks.each {|t| t.send("create_#{series}_points", *args)}
  end
  
  def create_estimated_cost_points
    p = self.estimated_cost_points.find_or_initialize_by_date(Date::today)
    if p.label.nil?
      p.series = :estimated_cost
      p.value = self.estimated_cost || 0
      p.save!
    end
  end
  
  def create_projected_cost_points
    p = self.projected_cost_points.find_or_initialize_by_date(Date::today)
    if p.label.nil?
      p.series = :projected_cost
      p.value = self.projected_cost || 0
      p.save!
    end
  end

  def create_cost_to_date_points(date)
    p = self.cost_to_date_points.find_or_create_by_date(date)
    if p.label.nil?
      p.series = :cost_to_date
      p.value = self.labor_cost_before(date) + self.material_cost_before(date)
      #p.value = self.cost_before(date)
      p.save!
    end
  end
  
  
  # Aggregators
  
  def estimated_fixed_cost
    estimated_raw_fixed_cost + self.components.joins(:fixed_cost_estimates => :markings ).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_unit_cost
    estimated_raw_unit_cost + self.components.joins(:unit_cost_estimates => :markings ).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_contract_cost
    estimated_raw_contract_cost + self.components.joins(:contracts => :markings ).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_cost
    estimated_fixed_cost + estimated_unit_cost + estimated_contract_cost
  end
  
  def estimated_raw_fixed_cost
    self.components.joins(:fixed_cost_estimates).sum('fixed_cost_estimates.raw_cost').to_f
  end
  def estimated_raw_unit_cost
    self.components.joins(:unit_cost_estimates).sum('unit_cost_estimates.raw_cost').to_f
  end
  def estimated_raw_contract_cost
    self.components.joins(:contracts).sum('contracts.estimated_raw_cost').to_f
  end
  def estimated_raw_cost
    estimated_raw_fixed_cost + estimated_raw_unit_cost + estimated_raw_contract_cost
  end

  def material_cost
    raw_material_cost + self.material_costs.joins(:markings).sum('markings.cost_markup_amount').to_f
  end
  def labor_cost
    raw_labor_cost + self.labor_costs.joins( :line_items => :markings).sum('markings.cost_markup_amount').to_f
  end
  def contract_cost
    raw_contract_cost + self.contracts.joins(:costs => :markings ).sum('markings.cost_markup_amount').to_f
  end
  def cost
    material_cost + labor_cost + contract_cost
  end
  
  def raw_material_cost
    self.material_costs.sum(:raw_cost).to_f
  end
  def raw_labor_cost
    self.labor_costs.joins(:line_items).sum('labor_cost_lines.raw_cost').to_f
  end
  def raw_contract_cost
    self.contracts.joins(:costs).sum('contract_costs.raw_cost').to_f
  end
  def raw_cost
    material_cost + labor_cost + contract_cost
  end

  def projected_cost
    self.tasks.inject(0) { |memo,obj| add_or_nil(memo, obj.projected_cost) } + 
    self.estimated_contract_cost + 
    ( FixedCostEstimate.unassigned.includes(:component).where('components.project_id = ?', self.id) ).sum(:cost).to_f + 
    ( UnitCostEstimate.unassigned.includes(:component).where('components.project_id = ?', self.id) ).sum(:cost).to_f
  end
  def raw_projected_cost
    self.tasks.inject(0) {|memo,obj| add_or_nil(memo, obj.raw_projected_cost)} + 
    self.estimated_raw_contract_cost +
    ( FixedCostEstimate.unassigned.includes(:component).where('components.project_id = ?', self.id) ).sum(:raw_cost).to_f + 
    ( UnitCostEstimate.unassigned.includes(:component).where('components.project_id = ?', self.id) ).sum(:raw_cost).to_f
  end
  
  def cascade_add(markup)
    #FixedCostEstimate.where("component_id in (?)", self.component_ids).each {|i| Marking.create :markup => markup, :markupable => i }
    #UnitCostEstimate.where("component_id in (?)", self.component_ids).each {|i| Marking.create :markup => markup, :markupable => i }
    #Contract.where("component_id in (?)", self.component_ids).each {|i| Marking.create :markup => markup, :markupable => i }
    #ContractCost.joins(:contract).where("contracts.component_id in (?)", self.component_ids).each {|i| Marking.create :markup => markup, :markupable => i }
    #LaborCostLine.joins(:labor_set).where("labor_costs.component_id in (?)", self.component_ids).each {|i| Marking.create :markup => markup, :markupable => i }
    #MaterialCost.where("component_id in (?)", self.component_ids).each {|i| Marking.create :markup => markup, :markupable => i }
    self.tasks.each {|i| Marking.create :markup => markup, :markupable => i }
    self.components.roots.each {|i| Marking.create :markup => markup, :markupable => i, :component_id => i.id }
  end
  
  def cascade_remove(markup)
    Marking.where(:markupable_type => 'FixedCostEstimate', :markup_id => markup.id).where( "markupable_id in (?)", FixedCostEstimate.where("component_id in (?)", self.component_ids).map(&:id) ).delete_all
    Marking.where(:markupable_type => 'UnitCostEstimate', :markup_id => markup.id).where( "markupable_id in (?)", UnitCostEstimate.where("component_id in (?)", self.component_ids).map(&:id) ).delete_all
    Marking.where(:markupable_type => 'Contract', :markup_id => markup.id).where( "markupable_id in (?)", Contract.where("component_id in (?)", self.component_ids).map(&:id) ).delete_all
    Marking.where(:markupable_type => 'ContractCost', :markup_id => markup.id).where( "markupable_id in (?)", ContractCost.joins(:contract).where("contracts.component_id in (?)", self.component_ids).map(&:id) ).delete_all
    Marking.where(:markupable_type => 'LaborCostLine', :markup_id => markup.id).where( "markupable_id in (?)", LaborCostLine.joins(:labor_set).where("labor_costs.component_id in (?)", self.component_ids).map(&:id) ).delete_all
    Marking.where(:markupable_type => 'MaterialCost', :markup_id => markup.id).where( "markupable_id in (?)", MaterialCost.where("component_id in (?)", self.component_ids).map(&:id) ).delete_all
    Marking.where(:markupable_type => 'Task', :markup_id => markup.id).where( "markupable_id in (?)", self.task_ids ).delete_all
    Marking.where(:markupable_type => 'Component', :markup_id => markup.id).where( "markupable_id in (?)", self.component_ids ).delete_all
  end
end
