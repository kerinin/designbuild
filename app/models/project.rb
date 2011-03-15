class Project < ActiveRecord::Base
  include AddOrNil
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  has_many :components, :order => "components.position", :dependent => :destroy
  has_many :tasks, :order => "tasks.name", :dependent => :destroy
  has_many :contracts, :order => "contracts.position", :dependent => :destroy
  has_many :deadlines, :order => "deadlines.date", :dependent => :destroy
  has_many :suppliers, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => [:cascade_add_markup, Proc.new{|p,d| p.save}], :after_remove => [:cascade_remove_markup, Proc.new{|p,d| p.save}]
  has_many :applied_markings, :class_name => 'Marking'
  
  has_many :invoices, :order => 'invoices.date DESC'
  has_many :payments, :order => 'payments.date DESC'
  
  has_many :estimated_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :estimated_cost}
  has_many :projected_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :projected_cost}
  has_many :cost_to_date_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :cost_to_date}
  
  has_and_belongs_to_many :users
  
  validates_presence_of :name
  validates_numericality_of :labor_percent_retainage, :material_percent_retainage
  
  before_save :cache_values
  before_save :create_estimated_cost_points, :if => proc {|i| i.estimated_cost_changed? && ( !i.new_record? || ( !i.estimated_cost.nil? && i.estimated_cost > 0 ) )}
  before_save :create_projected_cost_points, :if => proc {|i| i.projected_cost_changed? && ( !i.new_record? || ( !i.projected_cost.nil? && i.projected_cost > 0 ) )}
  # cost to date points being created at cost creation
  #before_save :create_cost_to_date_points, :if => proc {|i| i.cost_changed? && ( !i.new_record? || ( !i.cost.nil? && i.cost > 0 ) )}

  
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
  
  def cache_values
    [self.components, self.contracts, self.tasks].each {|a| a.reload}
    
    self.cache_estimated_fixed_cost
    self.cache_estimated_unit_cost
    self.cache_estimated_contract_cost
    self.cache_estimated_cost
    self.cache_material_cost
    self.cache_labor_cost
    self.cache_contract_cost
    self.cache_cost
    self.cache_projected_cost
  end
  
  
  # Invoicing
  [:labor_percent_retainage, :material_percent_retainage, :contract_percent_retainage].each do |sym|
    self.send(:define_method, "#{sym.to_s}_float") do
      divide_or_nil( self.send(sym), 100 ) || 0
    end
  end
  
  #:labor_cost, :material_cost, 
  [:labor_invoiced, :material_invoiced, :invoiced, :labor_retainage, :material_retainage, :retainage, :labor_paid, :material_paid, :paid, :labor_retained, :material_retained, :retained, :labor_outstanding, :material_outstanding, :outstanding].each do |sym|
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
      
  protected
    
  def cache_estimated_fixed_cost
    self.estimated_fixed_cost = self.components.roots.sum(:estimated_fixed_cost)
    self.estimated_raw_fixed_cost = self.components.roots.sum(:estimated_raw_fixed_cost)
  end
  
  def cache_estimated_unit_cost
    self.estimated_unit_cost = self.components.roots.sum(:estimated_unit_cost)
    self.estimated_raw_unit_cost = self.components.roots.sum(:estimated_raw_unit_cost)
  end
    
  def cache_estimated_contract_cost
    self.estimated_contract_cost = self.components.roots.sum(:estimated_contract_cost )
    self.estimated_raw_contract_cost = self.components.roots.sum(:estimated_raw_contract_cost )
  end

  def cache_estimated_cost
    self.estimated_cost = self.components.roots.sum(:estimated_cost)
    self.estimated_raw_cost = self.components.roots.sum(:estimated_raw_cost)
  end
  
  def cache_material_cost
    self.material_cost = self.tasks.sum(:material_cost)
    self.raw_material_cost = self.tasks.sum(:raw_material_cost)
  end
  
  def cache_labor_cost
    self.labor_cost = self.tasks.sum(:labor_cost)
    self.raw_labor_cost = self.tasks.sum(:raw_labor_cost)
  end
  
  def cache_contract_cost
    self.contract_cost = self.contracts.sum(:cost)
    self.raw_contract_cost = self.contracts.sum(:raw_cost)
  end
    
  def cache_cost
    self.cost = self.labor_cost + self.material_cost + self.contract_cost
    self.raw_cost = self.raw_labor_cost + self.raw_material_cost + self.raw_contract_cost
  end
  
  def cache_projected_cost
    self.projected_cost = self.tasks.inject(0) {|memo,obj| add_or_nil(memo, obj.projected_cost)} + 
      self.estimated_contract_cost + 
      ( FixedCostEstimate.unassigned.includes(:component).where('components.project_id = ?', self.id) ).sum(:cost).to_f + 
      ( UnitCostEstimate.unassigned.includes(:component).where('components.project_id = ?', self.id) ).sum(:cost).to_f
      
    self.raw_projected_cost = self.tasks.inject(0) {|memo,obj| add_or_nil(memo, obj.raw_projected_cost)} + 
      self.estimated_raw_contract_cost +
      ( FixedCostEstimate.unassigned.includes(:component).where('components.project_id = ?', self.id) ).sum(:raw_cost).to_f + 
      ( UnitCostEstimate.unassigned.includes(:component).where('components.project_id = ?', self.id) ).sum(:raw_cost).to_f    
  end
  
  
  def cascade_add_markup(markup)
    # Ancestry doesn't seem to like working with other associations...
    Component.roots.where(:project_id => self.id).all.each {|c| c.markups << markup unless c.markups.include? markup }

    self.tasks.all.each {|t| t.markups << markup unless t.markups.include? markup }
    self.save
  end
  
  def cascade_remove_markup(markup)
    # Ancestry doesn't seem to like working with other associations...
    Component.roots.where(:project_id => self.id).all.each {|c| c.markups.delete( markup ) }

    self.tasks.all.each {|t| t.markups.delete( markup ) }
    self.save
  end
end
