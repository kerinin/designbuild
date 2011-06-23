class Task < ActiveRecord::Base
  include AddOrNil
  
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
  has_many :markups, :through => :markings, :after_add => :refresh_markup, :after_remove => :refresh_markup
  
  has_many :estimated_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :estimated_cost}, :dependent => :destroy
  has_many :projected_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :projected_cost}, :dependent => :destroy
  has_many :cost_to_date_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :cost_to_date}, :dependent => :destroy
  
  validates_presence_of :name, :project

  after_create :add_project_markups
  
  #before_save :create_estimated_cost_points, :if => proc {|i| i.estimated_cost_changed? && ( !i.new_record? || ( !i.estimated_cost.nil? && i.estimated_cost > 0 ) )}
  #before_save :create_projected_cost_points, :if => proc {|i| i.projected_cost_changed? && ( !i.new_record? || ( !i.projected_cost.nil? && i.projected_cost > 0 ) )}
  # cost to date points being created at cost creation
  #before_save :create_cost_to_date_points, :if => proc {|i| i.cost_changed? && ( !i.new_record? || ( !i.cost.nil? && i.cost > 0 ) )}

  
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
  
  
  def refresh_markup(markup)
    LaborCostLine.includes(:labor_set).where('labor_costs.task_id' => self.id).each {|lcl| lcl.save!}
    self.material_costs.each {|mc| mc.save!}
    self.save!
  end
  
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

  def labor_cost_before(date)
    self.raw_labor_cost_before(date) + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_labor_cost_before, date)}
  end
  
  def raw_labor_cost_before(date)
    #self.labor_costs.where('date <= ?', date).all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.labor_costs.where('labor_costs.date <= ?', date).sum(:raw_cost)
  end
  
  def material_cost_before(date)
    self.raw_material_cost_before(date) + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_material_cost_before, date)}
  end
  
  def raw_material_cost_before(date)
    #self.material_costs.where('date <= ?', date).all.inject(nil) {|memo,obj| add_or_nil(memo, obj.raw_cost)}
    self.material_costs.where('material_costs.date <= ?', date).sum(:raw_cost)
  end
  
  def cost_before(date)
    add_or_nil labor_cost_before(date), material_cost_before(date)
  end
  
  def raw_cost_before(date)
    add_or_nil raw_labor_cost_before(date), raw_material_cost_before(date)
  end
  
  
  # Invoicing
  
  def labor_percent
    100 * ( divide_or_nil( self.labor_cost, self.cost ) || 0 )
  end
  
  def labor_percent_before(date)
    100 * ( divide_or_nil(self.labor_cost_before(date), self.cost_before(date) ) || 0)
  end
  
  def material_percent
    100 * ( divide_or_nil( self.material_cost, self.cost ) || 0 )
  end
  
  def material_percent_before(date)
    100 * (divide_or_nil(self.labor_cost_before(date), self.cost_before(date) ) || 0)
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
  
  def update_invoicing_state
    self.project.invoices.each {|i| i.save!}
    self.project.payments.each {|i| i.save!}
  end
     
        
  def add_project_markups
    self.project.markups.all.each {|m| self.markups << m unless self.markups.include? m }
  end
  
  def clear_associated
    self.fixed_cost_estimates.each {|fc| fc.task= nil; fc.save!}
    self.unit_cost_estimates.each {|uc| uc.task = nil; uc.save!}
  end
end
