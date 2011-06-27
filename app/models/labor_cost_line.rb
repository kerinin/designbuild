class LaborCostLine < ActiveRecord::Base  
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :project
  belongs_to :labor_set, :class_name => "LaborCost", :inverse_of => :line_items
  belongs_to :laborer, :inverse_of => :labor_cost_lines
  
  has_one :task, :through => :labor_set
  
  has_many :markings, :as => :markupable, :dependent => :destroy, :after_remove => proc {|i,m| m.destroy}, :uniq => true
  has_many :markups, :through => :markings, :dependent => :destroy, :uniq => true
  
  validates_presence_of :labor_set, :hours
  
  validates_numericality_of :hours
  
  after_create :inherit_markups, :update_markings
  
  before_save :set_costs
  before_save :update_markings, :if => proc {|i| i.component_id_changed? }, :unless => proc {|i| i.markings.empty? }
  
  before_save :set_project
  
  after_save :save_markings, :if => proc {|i| i.raw_cost_changed? }, :unless => proc {|i| i.markings.empty? }

  scope :by_project, lambda {|project| where(:project_id => project.id )  } 
  
  
  def inherit_markups
    self.task.markups(true).each {|m| self.markups << m unless self.markups.include?(m)}
  end
  
  def update_markings
    self.markings(true).update_all(:component_id => self.component_id)
  end
  
  def save_markings
    self.markings.each {|m| m.save!}
  end
  
  def cost
    self.raw_cost + self.markings.sum(:cost_markup_amount).to_f
  end
  
  def set_project
    self.project = self.labor_set.project
  end
  
  def set_costs
    unless self.laborer.blank?
      self.raw_cost = self.hours * self.laborer.bill_rate unless ( self.hours.nil? || self.laborer.blank? || self.laborer.bill_rate.nil? || self.laborer.destroyed? )
      #self.laborer_pay = self.hours * self.laborer.pay_rate unless ( self.hours.nil? || self.laborer.blank? || self.laborer.pay_rate.nil? || self.laborer.destroyed? )
    
      #self.cost = self.raw_cost + self.markups.inject(0) {|memo,obj| memo + obj.apply_to(self, :raw_cost) }
    end
  end
end
