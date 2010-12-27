class Task < ActiveRecord::Base
  include AddOrNil
  include MarksUp
  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :contract, :inverse_of => :tasks
  belongs_to :deadline, :inverse_of => :tasks
  belongs_to :project, :inverse_of => :tasks
  
  has_many :unit_cost_estimates, :order => :name
  has_many :fixed_cost_estimates, :order => :name
  has_many :labor_costs, :order => 'date DESC', :dependent => :destroy
  has_many :material_costs, :order => 'date DESC', :dependent => :destroy
  has_many :milestones, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings, :after_add => Proc.new{|t,m| t.save}, :after_remove => Proc.new{|t,m| t.save}
  
  validates_presence_of :name, :project

  after_create :add_project_markups
  
  before_save :cache_values
  
  after_save :cascade_cache_values
  after_destroy :cascade_cache_values
  
  after_save :update_invoicing_state
  
  scope :active, lambda {
    where(:active => true)
  }
  
  scope :completed, lambda {
    where( "#{table_name}.percent_complete >= 100" )
  }
  
  scope :future, lambda {
    where(:percent_complete => 0).where(:active => false)
  }
  
  def is_complete?
    self.percent_complete >= 100
  end
  
  def percent_complete_float
    self.percent_complete / 100
  end
  
  def percent_of_estimated
    multiply_or_nil(100, divide_or_nil(self.cost, self.estimated_cost))
  end
  
  def cost_estimates
    self.unit_cost_estimates.all + self.fixed_cost_estimates.all
  end
  
  def costs
    self.labor_costs.all + self.material_costs.all
  end
  
  def purchase_orders
    self.material_costs.where( :material_costs => {:raw_cost => nil} )
  end
  
  def completed_purchases
    self.material_costs.where( "material_costs.raw_cost IS NOT NULL" )
  end
  
  def projected_net
    subtract_or_nil self.estimated_cost, self.raw_projected_cost unless self.estimated_cost.nil?
  end

  def component_projected_net
    subtract_or_nil self.component_estimated_cost, self.raw_projected_cost unless self.component_estimated_cost.nil?
  end
    
  # -------------------CALCULATIONS
  
  # estimated_unit_cost
  #marks_up :estimated_raw_unit_cost
    
  # estimated_raw_unit_cost
  
  #def component_estimated_unit_cost
    #self.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil memo, obj.estimated_cost}
  #  self.unit_cost_estimates.sum(:estimated_cost)
  #end
    
  #def component_estimated_raw_unit_cost
    #self.unit_cost_estimates.inject(nil) {|memo,obj| add_or_nil memo, obj.estimated_raw_cost}
  #  self.unit_cost_estimates.sum(:estimated_raw_cost)
  #end
  
  # estimated_fixed_cost
  #marks_up :estimated_raw_fixed_cost
  
  # estimated_raw_fixed_cost

  #def component_estimated_fixed_cost
    #self.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil memo, obj.estimated_cost}
  #  self.fixed_cost_estimates.sum(:estimated_cost)
  #end
    
  #def component_estimated_raw_fixed_cost
    #self.fixed_cost_estimates.inject(nil) {|memo,obj| add_or_nil memo, obj.estimated_raw_cost}
  #  self.fixed_cost_estimates.sum(:estimated_raw_cost)
  #end
    
  #def estimated_cost
  #  add_or_nil(estimated_fixed_cost, estimated_unit_cost)
  #end
  
  #def component_estimated_cost
  #  add_or_nil(component_estimated_fixed_cost, component_estimated_unit_cost)
  #end
  
  #def estimated_raw_cost
  #  add_or_nil(estimated_raw_fixed_cost, estimated_raw_unit_cost)
  #end
  
  #def component_estimated_raw_cost
  #  add_or_nil(component_estimated_raw_fixed_cost, component_estimated_raw_unit_cost)
  #end
  
  # labor_cost
  #marks_up :raw_labor_cost
  
  marks_up :raw_labor_cost_before
  def raw_labor_cost_before(date = Date::today)
    #self.labor_costs.where('date <= ?', date).all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.labor_costs.where('date <= ?', date).sum(:raw_cost)
  end
  
  # raw_labor_cost
  
  # material_cost
  #marks_up :raw_material_cost
  
  # raw_material_cost
  
  marks_up :raw_material_cost_before
  def raw_material_cost_before(date = Date::today)
    #self.material_costs.where('date <= ?', date).all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.material_costs.where('date <= ?', date).sum(:raw_cost)
  end
  
  #def cost
  #  add_or_nil(labor_cost, material_cost)
  #end
  
  #def raw_cost
  #  add_or_nil(raw_labor_cost, raw_material_cost)
  #end
  
  marks_up :raw_cost_before
  def raw_cost_before(date = Date::today)
    add_or_nil raw_labor_cost_before(date), raw_material_cost_before(date)
  end
  
  # projected_cost
  #marks_up :raw_projected_cost
  
  #def raw_projected_cost
  #  if self.percent_complete >= 100
  #    return self.raw_cost
  #  end
      
    # This comparison should work for raw and marked-up, since both will be
    # mutliplied by the same markup (per-task)
  #  est = self.estimated_raw_cost
  #  act = self.raw_cost
  #  if act.nil?
  #    return self.estimated_raw_cost
  #  elsif est.nil?
  #    return self.raw_cost
  #  elsif act > est
  #    return self.raw_cost
  #  else
  #    return self.estimated_raw_cost
  #  end
  #end
  
  #def percent_complete
  #  self.labor_costs.empty? ? 0 : self.labor_costs.first.percent_complete
  #end
  
  
  def cache_values
    #puts "caching from task"
    [self.unit_cost_estimates, self.fixed_cost_estimates, self.labor_costs, self.material_costs, self.markups].each {|a| a.reload}
  
    self.cache_total_markup
    self.cache_estimated_unit_cost
    self.cache_estimated_fixed_cost
    self.cache_estimated_cost
    self.cache_labor_cost
    self.cache_material_cost
    self.cache_cost
    self.cache_projected_cost
    #puts self.material_costs(true).count
    #puts self.raw_material_cost
  end
    
  def cascade_cache_values
    self.project.save!
  end
  
  
  
  # Invoicing
  
  def labor_percent
    100 * ( divide_or_nil( self.labor_cost, self.cost ) || 0 )
  end
  
  def labor_percent_before(date=Date::today)
    100 * ( divide_or_nil(self.labor_cost_before(date), self.cost_before(date) ) || 0)
  end
  
  def material_percent
    100 * ( divide_or_nil( self.material_cost, self.cost ) || 0 )
  end
  
  def material_percent_before(date=Date::today)
    100 * (divide_or_nil(self.labor_cost_before(date), self.cost_before(date) ) || 0)
  end
  
  protected
    
  def cache_estimated_unit_cost
    #self.estimated_raw_unit_cost = self.unit_cost_estimates.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.estimated_raw_unit_cost = self.unit_cost_estimates.sum(:raw_cost)
    self.estimated_unit_cost = mark_up self.estimated_raw_unit_cost
    self.component_estimated_raw_unit_cost = self.unit_cost_estimates.sum(:estimated_raw_cost)
    self.component_estimated_unit_cost = self.unit_cost_estimates.sum(:estimated_cost)
  end
  
  def cache_estimated_fixed_cost
    #self.estimated_raw_fixed_cost = self.fixed_cost_estimates.all.inject(nil) {|memo,obj| add_or_nil(memo,obj.raw_cost)}
    self.estimated_raw_fixed_cost = self.fixed_cost_estimates.sum(:raw_cost)
    self.estimated_fixed_cost = mark_up self.estimated_raw_fixed_cost
    self.component_estimated_raw_fixed_cost = self.fixed_cost_estimates.sum(:estimated_raw_cost)
    self.component_estimated_fixed_cost = self.fixed_cost_estimates.sum(:estimated_cost)
  end

  def cache_estimated_cost
    self.estimated_raw_cost = add_or_nil(estimated_raw_fixed_cost, estimated_raw_unit_cost)
    self.estimated_cost = add_or_nil(estimated_fixed_cost, estimated_unit_cost)
    self.component_estimated_cost = add_or_nil(component_estimated_fixed_cost, component_estimated_unit_cost)
    self.component_estimated_raw_cost = add_or_nil(component_estimated_raw_fixed_cost, component_estimated_raw_unit_cost)
  end
  
  def cache_labor_cost
    #self.raw_labor_cost = self.labor_costs.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.raw_labor_cost = self.labor_costs.sum(:raw_cost)
    self.labor_cost = mark_up self.raw_labor_cost
  end

  def cache_material_cost
    #self.raw_material_cost = self.material_costs.all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.raw_material_cost = self.material_costs.sum(:raw_cost)
    self.material_cost = mark_up self.raw_material_cost
  end 
  
  def cache_cost
    self.raw_cost = add_or_nil(raw_labor_cost, raw_material_cost)
    self.cost = add_or_nil(labor_cost, material_cost)
  end
  
  def cache_projected_cost
    if self.percent_complete >= 100
      self.raw_projected_cost = self.raw_cost
    else
      # This comparison should work for raw and marked-up, since both will be
      # mutliplied by the same markup (per-task)
      est = self.estimated_raw_cost
      act = self.raw_cost
      if act.nil?
        self.raw_projected_cost = self.estimated_raw_cost
      elsif est.nil?
        self.raw_projected_cost = self.raw_cost
      elsif act > est
        self.raw_projected_cost = self.raw_cost
      else
        self.raw_projected_cost = self.estimated_raw_cost
      end 
    end
    
    self.projected_cost = mark_up self.raw_projected_cost
  end
  
  def cache_total_markup
    #self.total_markup = self.markups.all.inject(0) {|memo,obj| memo + obj.percent }
    self.total_markup = self.markups.sum(:percent)
  end
  
  
  def update_invoicing_state
    self.project.invoices.each {|i| i.save!}
    self.project.payments.each {|i| i.save!}
  end
     
        
  def add_project_markups
    self.project.markups.all.each {|m| self.markups << m unless self.markups.include? m }
  end
end
