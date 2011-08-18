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
  has_many :markups, :through => :markings, :dependent => :destroy, :after_remove => :cascade_remove
  
  has_many :estimated_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :estimated_cost}, :dependent => :destroy
  has_many :projected_cost_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :projected_cost}, :dependent => :destroy
  has_many :cost_to_date_points, :as => :source, :class_name => 'DatePoint', :order => :date, :conditions => {:series => :cost_to_date}, :dependent => :destroy
  
  validates_presence_of :name, :project

  after_create :inherit_markups
  
  #before_save :create_estimated_cost_points, :if => proc {|i| i.estimated_cost_changed? && ( !i.new_record? || ( !i.estimated_cost.nil? && i.estimated_cost > 0 ) )}
  #before_save :create_projected_cost_points, :if => proc {|i| i.projected_cost_changed? && ( !i.new_record? || ( !i.projected_cost.nil? && i.projected_cost > 0 ) )}
  # cost to date points being created at cost creation
  #before_save :create_cost_to_date_points, :if => proc {|i| i.cost_changed? && ( !i.new_record? || ( !i.cost.nil? && i.cost > 0 ) )}

  after_save :update_invoicing_state
  
  after_destroy :clear_associated
  
  scope :active, lambda {
    where(:active => true)
  }
  
  scope :completed, lambda {
    #where( "#{table_name}.percent_complete >= 100" )
    where(:active => false)
  }
  
  scope :future, lambda {
    #where(:percent_complete => 0).where(:active => false)
    where(:active => nil)
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
    self.estimated_cost - self.raw_projected_cost
  end

  def component_projected_net
    self.component_estimated_cost - self.raw_projected_cost
  end

  def labor_cost_before( date = Date::today )
    raw_labor_cost_before(date) + self.labor_costs.joins(:line_items => :markings).where( "labor_costs.date <= ?", date ).sum('markings.cost_markup_amount').to_f
  end
    
  def raw_labor_cost_before( date = Date::today )
    self.labor_costs.joins(:line_items).where( "labor_costs.date <= ?", date ).sum('labor_cost_lines.raw_cost').to_f
  end
    
  def material_cost_before( date = Date::today )
    raw_material_cost_before(date) + self.material_costs.joins(:markings).where( "material_costs.date <= ?", date ).sum('markings.cost_markup_amount').to_f
  end
    
  def raw_material_cost_before( date = Date::today )
    self.material_costs.where( "material_costs.date <= ?", date ).sum('material_costs.raw_cost').to_f
  end
    
  def cost_before(date)
    labor_cost_before(date) + material_cost_before(date)
  end
  
  def raw_cost_before(date)
    raw_labor_cost_before(date) + raw_material_cost_before(date)
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
    
  def estimated_unit_cost
    estimated_raw_unit_cost + self.unit_cost_estimates.joins(:markings).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_fixed_cost
    estimated_raw_fixed_cost + self.fixed_cost_estimates.joins(:markings).sum('markings.estimated_cost_markup_amount').to_f
  end
  def estimated_cost
    estimated_unit_cost + estimated_fixed_cost
  end

  def estimated_raw_unit_cost
    self.unit_cost_estimates.sum('unit_cost_estimates.raw_cost').to_f
  end
  def estimated_raw_fixed_cost
    self.fixed_cost_estimates.sum('fixed_cost_estimates.raw_cost').to_f
  end
  def estimated_raw_cost
    estimated_raw_unit_cost + estimated_raw_fixed_cost
  end
  
  def labor_cost
    raw_labor_cost + self.labor_costs.joins(:line_items => :markings).sum('markings.cost_markup_amount').to_f
  end
  def material_cost
    raw_material_cost + self.material_costs.joins(:markings).sum('markings.cost_markup_amount').to_f
  end
  def cost
    labor_cost + material_cost
  end

  def raw_labor_cost
    self.labor_costs.joins(:line_items).sum('labor_cost_lines.raw_cost').to_f
  end
  def raw_material_cost
    self.material_costs.sum('material_costs.raw_cost').to_f
  end
  def raw_cost
    raw_labor_cost + raw_material_cost
  end

  def projected_cost
    if self.percent_complete >= 100
      self.cost
    else
      est = self.estimated_cost
      act = self.cost
      
      if act.nil?
        est
      elsif est.nil?
        act
      elsif act > est
        act
      else
        est
      end
    end
  end
      
  def raw_projected_cost
    if self.percent_complete >= 100
      self.raw_cost
    else
      est = self.estimated_raw_cost
      act = self.raw_cost
      
      if act.nil?
        est
      elsif est.nil?
        act
      elsif act > est
        act
      else
        est
      end
    end
  end
  
  def cascade_add(markup)
    LaborCostLine.where("labor_set_id in (?)", self.labor_cost_ids).each {|i| Marking.create :markup => markup, :markupable => i }
    self.material_costs.each {|i| Marking.create :markup => markup, :markupable => i }
  end
  
  def cascade_remove(markup)
    Marking.where(:markupable_type => 'LaborCostLine', :markup_id => markup.id).where( "markupable_id in (?)", LaborCostLine.where("labor_set_id in (?)", self.labor_cost_ids).map(&:id) ).delete_all
    Marking.where(:markupable_type => 'MaterialCost', :markup_id => markup.id).where( "markupable_id in (?)", self.material_cost_ids ).delete_all
  end
  
  protected
  
  def update_invoicing_state
    self.project.invoices.each {|i| i.save!}
    self.project.payments.each {|i| i.save!}
  end
        
  def inherit_markups
    self.project.markups(true).each {|m| self.markups << m unless self.markups.include?(m)}
  end
  
  def clear_associated
    self.fixed_cost_estimates.each {|fc| fc.task= nil; fc.save!}
    self.unit_cost_estimates.each {|uc| uc.task = nil; uc.save!}
  end
end
