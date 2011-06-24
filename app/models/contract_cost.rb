class ContractCost < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
    
  belongs_to :contract, :inverse_of => :costs
  belongs_to :component
  
  has_many :markings, :as => :markupable, :dependent => :destroy, :after_remove => proc {|i,m| m.destroy}
  has_many :markups, :through => :markings, :dependent => :destroy
  
  validates_presence_of :date, :raw_cost, :contract
  
  validates_numericality_of :raw_cost
  
  after_create :inherit_markups
  
  before_save :assign_component
  before_save :update_markings, :if => proc {|i| i.component_id_changed? }, :unless => proc {|i| i.markings.empty? }

  after_save :save_markings, :if => proc {|i| i.raw_cost_changed? }, :unless => proc {|i| i.markings.empty? }
  
  def inherit_markups
    self.contract.markups.each {|m| self.markups << m unless self.markups.include?(m)}
  end
  
  def update_markings
    self.markings.update_all(:component_id => self.component_id)
  end
  
  def save_markings
    self.markings.each {|m| m.save!}
  end
  
  def cost
    self.raw_cost + self.markings.sum(:cost_markup_amount)
  end
  
  def assign_component
    self.component_id = self.contract.component_id
  end
  
  protected
  
  def create_points
    self.contract.project.create_cost_to_date_points(self.date)
    self.contract.create_cost_to_date_points(self.date)
    
    #p = self.contract.project.cost_to_date_points.find_or_create_by_date(self.date)
    #if p.label.nil?
    #  p.series = :cost_to_date
    #  p.value = self.contract.project.labor_cost_before(self.date) + self.contract.project.material_cost_before(self.date)
    #  p.save!
    #end

    #p = self.contract.cost_to_date_points.find_or_create_by_date(self.date)
    #if p.label.nil?
    #  p.series = :cost_to_date
    #  p.value = self.contract.cost_before(self.date)
    #  p.save!
    #end
  end
end
