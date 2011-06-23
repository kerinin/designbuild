class Marking < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :markupable, :polymorphic => true
  belongs_to :project
  belongs_to :component

  belongs_to :markup
  
  before_save :set_project
  
  validates_presence_of :markupable, :markup, :project
  
  def set_project
    self.project = self.markupable.class == Project ? self.markupable : self.markupable.project
  end
  
  def set_markup_amount_from!(markupable)
    if markupable.class == Component
      self.estimated_unit_cost_markup_amount = self.markup.apply_to(markupable, :estimated_raw_component_unit_cost)
      self.estimated_fixed_cost_markup_amount = self.markup.apply_to(markupable, :estimated_raw_component_fixed_cost)
      self.estimated_contract_cost_markup_amount = self.markup.apply_to(markupable, :estimated_raw_component_contract_cost)
      self.estimated_cost_markup_amount = (
        self.estimated_unit_cost_markup_amount + 
        self.estimated_fixed_cost_markup_amount +
        self.estimated_contract_cost_markup_amount
      )
      self.labor_cost_markup_amount = 0
      self.material_cost_markup_amount = 0
      self.cost_markup_amount = 0
          
    elsif self.markupable.class == Task
      self.estimated_unit_cost_markup_amount = self.markup.apply_to(markupable, :estimated_raw_unit_cost)
      self.estimated_fixed_cost_markup_amount = self.markup.apply_to(markupable, :estimated_raw_fixed_cost)
      self.estimated_contract_cost_markup_amount = 0
      self.estimated_cost_markup_amount = (
        self.estimated_unit_cost_markup_amount +
        self.estimated_fixed_cost_markup_amount +
        self.estimated_contract_cost_markup_amount
      )
      
      self.labor_cost_markup_amount = self.markup.apply_to(markupable, :raw_labor_cost)
      self.material_cost_markup_amount = self.markup.apply_to(markupable, :raw_material_cost)
      self.cost_markup_amount = self.labor_cost_markup_amount + material_cost_markup_amount
    end
    
    self.save!
  end
end
