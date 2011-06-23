class Marking < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :markupable, :polymorphic => true
  belongs_to :project
  belongs_to :component

  belongs_to :markup
  
  before_save :set_project, :set_markup_amount
  
  validates_presence_of :markupable, :markup, :project
  
  def set_project
    self.project = self.markupable.class == Project ? self.markupable : self.markupable.project
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
