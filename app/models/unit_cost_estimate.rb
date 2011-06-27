class UnitCostEstimate < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  #has_invoices
  
  belongs_to :component, :inverse_of => :unit_cost_estimates
  belongs_to :quantity, :inverse_of => :unit_cost_estimates
  belongs_to :task, :inverse_of => :unit_cost_estimates

  has_many :markings, :as => :markupable, :dependent => :destroy, :after_remove => proc {|i,m| m.destroy}, :uniq => true
  has_many :markups, :through => :markings, :dependent => :destroy, :uniq => true
    
  accepts_nested_attributes_for :quantity, :reject_if => :all_blank
  
  validates_presence_of :name, :quantity, :unit_cost
  validates_numericality_of :unit_cost
  
  after_create :inherit_markups, :update_markings
  
  before_save :set_component, :set_raw_cost
  before_save :update_markings, :if => proc {|i| i.component_id_changed? }, :unless => proc {|i| i.markings.empty? }
  
  after_save :save_markings, :if => proc {|i| i.raw_cost_changed? }, :unless => proc {|i| i.markings.empty? }
  
  scope :assigned, lambda { where( 'task_id IS NOT NULL' ) }
  
  scope :unassigned, lambda { where( {:task_id => nil} ) }
  
  def inherit_markups
    self.component.markups(true).each {|m| self.markups << m unless self.markups.include?(m)}
  end
  
  def update_markings
    self.markings(true).update_all(:component_id => self.component_id)
  end
  
  def save_markings
    self.markings.each {|m| m.save!}
  end
  
  def cost
    self.raw_cost + self.markings.sum(:estimated_cost_markup_amount)
  end
  
  def task_name=(string)
    self.task = (string == '' || string.nil?) ? nil : Task.find_or_create_by_name_and_project_id(string, self.component.project_id)
  end
  
  def task_name
    self.task.blank? ? nil : self.task.name
  end
  
  def estimated_cost
    self.cost
  end
  
  def estimated_raw_cost
    self.raw_cost
  end
  
  
  # Invoicing
  [:labor_cost, :material_cost].each do |sym|
    self.send(:define_method, sym) do
      if self.task.blank? || self.task.send(sym).nil? || self.estimated_cost.nil? 
        0
      else
        task_cost = self.task.send(sym)
        my_share = case
        when task.unit_cost_estimates.count + task.fixed_cost_estimates.count == 1
          1
        when !self.estimated_cost.nil? && self.task.estimated_cost > 0
          self.estimated_cost / self.task.estimated_cost
        else
          1 / (self.task.unit_cost_estimates.count + self.task.fixed_cost_estimates)
        end
        
        return task_cost * my_share
      end
    end
  end
  
  [:labor_cost_before, :material_cost_before].each do |sym|
    self.send(:define_method, sym) do |date|
      date ||= Date::today
      if self.task.blank? || self.task.send(sym, date).nil? || self.estimated_cost.nil?
        0
      else
        task_cost = self.task.send(sym, date)
        my_share = case
        when task.unit_cost_estimates.count + task.fixed_cost_estimates.count == 1
          1
        when !self.estimated_cost.nil? && self.task.estimated_cost > 0
          self.estimated_cost / self.task.estimated_cost
        else
          1 / (self.task.unit_cost_estimates.count + self.task.fixed_cost_estimates)
        end
        
        return task_cost * my_share
      end
    end
  end
  
  def percent_complete
    self.task.percent_complete unless self.task.blank?
  end
  
  def percent_complete_float
    self.task.percent_complete_float unless self.task.blank?
  end
  
  protected
  
  def set_raw_cost
    self.raw_cost = self.quantity.value * self.unit_cost * ( self.drop.nil? ? 1 : (1.0 + (self.drop / 100.0) ) )
  end
  
  def set_component
    self.component ||= self.quantity.component
  end
end
