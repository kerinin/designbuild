class Marking < ActiveRecord::Base
  has_paper_trail :ignore => [:created_at, :updated_at]
  
  belongs_to :markupable, :polymorphic => true, :inverse_of => :markings
  belongs_to :project
  belongs_to :component

  belongs_to :markup, :inverse_of => :markings
  
  after_create :cascade_add
  
  #before_save :set_component
  before_validation :set_project
  #before_save :set_markup_amount
  
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
      self.component_id = self.markupable_id
    when "FixedCostEstimate", "UnitCostEstimate", "Contract", "MaterialCost"
      self.component_id = self.markupable.component_id
      #puts "Setting component id: #{self.component_id}"
    when "ContractCost"
      self.component_id = self.markupable.contract.component_id
    when "LaborCostLine"
      self.component_id = self.markupable.labor_set.component_id
    end
  end    
  
  def safeadd_markup(id, markupable, component_id=nil)
    begin
      Marking.create(:markup_id => id, :markupable => markupable, :component_id => component_id)
    rescue ActiveRecord::RecordInvalid => e
      raise e unless e.message == 'Validation failed: Markup has already been taken'
    end
  end
  
  def cascade_add
    #puts "Cascading add from #{self.markupable_type} #{self.markupable_id}"
    m = self.markupable
    marking = self
    case self.markupable_type
    when "Component"
      FixedCostEstimate.where("component_id in (?)", m.subtree_ids).each {|i| safeadd_markup( marking.markup_id, i, i.component_id ) }
      UnitCostEstimate.where("component_id in (?)", m.subtree_ids).each {|i| safeadd_markup( marking.markup_id, i, i.component_id ) }
      Contract.where("component_id in (?)", m.subtree_ids).each {|i| safeadd_markup( marking.markup_id, i, i.component_id ) }
      ContractCost.joins(:contract).where("contracts.component_id in (?)", m.subtree_ids).each {|i| safeadd_markup( marking.markup_id, i, i.contract.component_id ) }
      LaborCostLine.joins(:labor_set).where("labor_costs.component_id in (?)", m.subtree_ids).each {|i| safeadd_markup(  marking.markup_id, i, i.labor_set.component_id ) }
      MaterialCost.where("component_id in (?)", m.subtree_ids).each {|i| safeadd_markup( marking.markup_id, i, i.component_id ) }
      m.subtree.each {|i| safeadd_markup( marking.markup_id, i, i.id) }
    when "Contract"
      m.costs.each {|i| safeadd_markup( marking.markup_id, i, m.component_id ) }
    when "Project"
      FixedCostEstimate.where("component_id in (?)", m.component_ids).each {|i| safeadd_markup( marking.markup_id, i, i.component_id) }
      UnitCostEstimate.where("component_id in (?)", m.component_ids).each {|i| safeadd_markup( marking.markup_id, i, i.component_id) }
      Contract.where("component_id in (?)", m.component_ids).each {|i| safeadd_markup( marking.markup_id, i, i.component_id) }
      ContractCost.joins(:contract).where("contracts.component_id in (?)", m.component_ids).each {|i| safeadd_markup( marking.markup_id, i, i.contract.component_id) }
      LaborCostLine.joins(:labor_set).where("labor_costs.component_id in (?)", m.component_ids).each {|i| safeadd_markup( marking.markup_id, i, i.labor_set.component_id) }
      MaterialCost.where("component_id in (?)", m.component_ids).each {|i| safeadd_markup( marking.markup_id, i, i.component_id) }
      m.tasks.each {|i| safeadd_markup( marking.markup_id, i) }
      m.components.each {|i| safeadd_markup( marking.markup_id, i, i.id) }
    when "Task"
      LaborCostLine.where("labor_set_id in (?)", m.labor_cost_ids).each {|i| safeadd_markup( marking.markup_id, i, i.labor_set.component_id) }
      m.material_costs.each {|i| safeadd_markup( marking.markup_id, i, i.component_id) }
    end
  end
  
  def cascade_remove
    puts "Cascading remove from #{self.markupable_type} #{self.markupable_id}"
    m = self.markupable
    case self.markupable_type
    when "Component"
      Marking.where(:markupable_type => 'FixedCostEstimate', :markup_id => self.markup_id).where( "markupable_id in (?)", FixedCostEstimate.where("component_id in (?)", m.subtree_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'UnitCostEstimate', :markup_id => self.markup_id).where( "markupable_id in (?)", UnitCostEstimate.where("component_id in (?)", m.subtree_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'Contract', :markup_id => self.markup_id).where( "markupable_id in (?)", Contract.where("component_id in (?)", m.subtree_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'ContractCost', :markup_id => self.markup_id).where( "markupable_id in (?)", ContractCost.joins(:contract).where("contracts.component_id in (?)", m.subtree_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'LaborCostLine', :markup_id => self.markup_id).where( "markupable_id in (?)", LaborCostLine.joins(:labor_set).where("labor_costs.component_id in (?)", m.subtree_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'MaterialCost', :markup_id => self.markup_id).where( "markupable_id in (?)", MaterialCost.where("component_id in (?)", m.subtree_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'Component', :markup_id => self.markup_id).where( "markupable_id in (?)", m.subtree_ids ).delete_all
    when "Contract"
      Marking.where(:markupable_type => 'ContractCost', :markup_id => self.markup_id).where( "markupable_id in (?)", m.cost_ids ).delete_all
    when "Project"
      Marking.where(:markupable_type => 'FixedCostEstimate', :markup_id => self.markup_id).where( "markupable_id in (?)", FixedCostEstimate.where("component_id in (?)", m.component_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'UnitCostEstimate', :markup_id => self.markup_id).where( "markupable_id in (?)", UnitCostEstimate.where("component_id in (?)", m.component_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'Contract', :markup_id => self.markup_id).where( "markupable_id in (?)", Contract.where("component_id in (?)", m.component_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'ContractCost', :markup_id => self.markup_id).where( "markupable_id in (?)", ContractCost.joins(:contract).where("contracts.component_id in (?)", m.component_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'LaborCostLine', :markup_id => self.markup_id).where( "markupable_id in (?)", LaborCostLine.joins(:labor_set).where("labor_costs.component_id in (?)", m.component_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'MaterialCost', :markup_id => self.markup_id).where( "markupable_id in (?)", MaterialCost.where("component_id in (?)", m.component_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'Task', :markup_id => self.markup_id).where( "markupable_id in (?)", m.task_ids ).delete_all
      Marking.where(:markupable_type => 'Component', :markup_id => self.markup_id).where( "markupable_id in (?)", m.component_ids ).delete_all
    when "Task"
      Marking.where(:markupable_type => 'LaborCostLine', :markup_id => self.markup_id).where( "markupable_id in (?)", LaborCostLine.where("labor_set_id in (?)", m.labor_cost_ids).map(&:id) ).delete_all
      Marking.where(:markupable_type => 'MaterialCost', :markup_id => self.markup_id).where( "markupable_id in (?)", m.material_cost_ids ).delete_all
    end
  end
end
