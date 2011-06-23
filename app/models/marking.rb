class Marking < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :markupable, :polymorphic => true
  belongs_to :project
  belongs_to :component

  belongs_to :markup
  
  before_validation :set_project
  before_save :set_markup_amount
  
  validates_presence_of :markupable, :markup, :project
  
  def set_project
    self.project = self.markupable_type == "Project" ? self.markupable : self.markupable.project
  end
  
  def set_markup_amount
    case self.markupable_type
    when "FixedCostEstimate", "UnitCostEstimate", "Contract"
      self.estimated_cost_markup_amount = self.markup.apply_to(self.markupable, :estimated_raw_cost)
    when "LaborCost", "MaterialCost", "ContractCost"
      self.cost_markup_amount = self.markup.apply_to(self.markupable, :raw_cost)
    end
  end
end
