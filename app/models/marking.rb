class Marking < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :markupable, :polymorphic => true, :inverse_of => :markings
  belongs_to :project
  belongs_to :component

  belongs_to :markup, :inverse_of => :markings
  
  #before_create :set_component
  after_create :cascade_add
  
  before_validation :set_project
  before_save :set_markup_amount, :set_component
  
  #after_destroy :cascade_remove
  
  validates_presence_of :markupable, :markup, :project
  validates_uniqueness_of :markup_id, :scope => [:markupable_id, :markupable_type]
  
  def set_project
    case self.markupable_type
    when "Project"
      self.project_id = self.markupable.id
    when "ContractCost"
      self.project_id = self.markupable.contract.project_id
    when "FixedCostEstimate", 'UnitCostEstimate'
      self.project_id = self.markupable.component.project_id
    when "LaborCostLine"
      self.project_id = self.markupable.labor_set.project_id
    else
      self.project_id = self.markupable.project_id
    end
  end
  
  def set_markup_amount
    case self.markupable_type
    when "FixedCostEstimate", "UnitCostEstimate", "Contract"
      self.estimated_cost_markup_amount = self.markup.apply_to(self.markupable, :estimated_raw_cost) || 0
    when "LaborCostLine", "MaterialCost", "ContractCost"
      self.cost_markup_amount = self.markup.apply_to(self.markupable, :raw_cost) || 0
    end
  end
  
  def set_component
    #puts "set_component, type #{self.markupable_type}"
    case self.markupable_type
    when "Component"
      self.component_id ||= self.markupable_id
    when "FixedCostEstimate", "UnitCostEstimate", "Contract", "MaterialCost"
      self.component_id ||= self.markupable.component_id
    when "ContractCost"
      self.component_id ||= self.markupable.contract.component_id
    when "LaborCostLine"
      self.component_id ||= self.markupable.labor_set.component_id
    #else
    #  puts "markupable_type not recognized (#{self.markupable_type})"
    end
  end    
  
  def self.safeadd(markup, markupable, component_id = nil)
    begin
      Marking.create(:markup => markup, :markupable => markupable, :component_id => component_id)
    rescue ActiveRecord::RecordInvalid => e
      raise e unless e.message == 'Validation failed: Markup has already been taken'
    end
  end
  
  def cascade_add
    self.markupable.send(:cascade_add, self.markup) if self.markupable.respond_to? :cascade_add
  end
end
