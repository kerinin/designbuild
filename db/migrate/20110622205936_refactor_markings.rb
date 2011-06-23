class Markup < ActiveRecord::Base
  has_many :markings, :dependent => :destroy
  
  has_many :projects, :through => :markings, :source => :markupable, :source_type => 'Project'
  has_many :tasks, :through => :markings, :source => :markupable, :source_type => 'Task'
  has_many :components, :through => :markings, :source => :markupable, :source_type => 'Component'
  
  has_many :unit_cost_estimates, :through => :markings, :source => :markupable, :source_type => 'UnitCostEstimate'
  has_many :fixed_cost_estimates, :through => :markings, :source => :markupable, :source_type => 'FixedCostEstimate'
  has_many :contracts, :through => :markings, :source => :markupable, :source_type => 'Contract'
  
  has_many :invoice_markup_lines
  has_many :payment_markup_lines  
  
  def apply_to(value, method = nil, *args)
    if value.instance_of?( Float ) || value.instance_of?( Integer )
      multiply_or_nil( value, divide_or_nil(self.percent, 100) )
    else
      multiply_or_nil( value.send(method, *args), divide_or_nil(self.percent, 100))
    end
  end
end

class Marking < ActiveRecord::Base
  belongs_to :markupable, :polymorphic => true
  belongs_to :project

  belongs_to :markup
  
  before_save :set_project
  
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
end

class Project < ActiveRecord::Base
  has_many :components, :dependent => :destroy
  has_many :tasks, :dependent => :destroy
  has_many :contracts, :dependent => :destroy
  
  has_many :applied_markings, :class_name => 'Marking'
end

class Component < ActiveRecord::Base
  belongs_to :project, :inverse_of => :components
  
  has_many :fixed_cost_estimates, :dependent => :destroy
  has_many :unit_cost_estimates, :dependent => :destroy
  has_many :contracts, :dependent => :destroy  
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
end

class FixedCostEstimate < ActiveRecord::Base
  belongs_to :component, :inverse_of => :fixed_cost_estimates
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
  
  def project
    self.component.project
  end
end

class UnitCostEstimate < ActiveRecord::Base
  belongs_to :component, :inverse_of => :unit_cost_estimates
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
  
  def project
    self.component.project
  end
end

class Contract < ActiveRecord::Base
  belongs_to :project, :inverse_of => :contracts
  belongs_to :component, :inverse_of => :contracts
  
  has_many :costs, :class_name => "ContractCost"
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
end

class Task < ActiveRecord::Base
  belongs_to :contract, :inverse_of => :tasks
  belongs_to :project, :inverse_of => :tasks
  
  has_many :unit_cost_estimates
  has_many :fixed_cost_estimates
  has_many :labor_costs, :dependent => :destroy
  has_many :material_costs, :dependent => :destroy

  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
end

class LaborCost < ActiveRecord::Base
  belongs_to :project
  belongs_to :component
  belongs_to :task, :inverse_of => :labor_costs
  
  has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy
end

class LaborCostLine < ActiveRecord::Base
  belongs_to :labor_set, :class_name => "LaborCost", :inverse_of => :line_items
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
end

class MaterialCost < ActiveRecord::Base
  belongs_to :project
  belongs_to :component
  belongs_to :task, :inverse_of => :material_costs
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
end

class ContractCost < ActiveRecord::Base
  belongs_to :contract, :inverse_of => :costs
  
  has_many :markings, :as => :markupable, :dependent => :destroy
  has_many :markups, :through => :markings
  
  def project
    self.contract.project
  end
end


class RefactorMarkings < ActiveRecord::Migration
  def self.up
    remove_column :markings, :estimated_unit_cost_markup_amount
    remove_column :markings, :estimated_fixed_cost_markup_amount
    remove_column :markings, :estimated_contract_cost_markup_amount
    remove_column :markings, :estimated_cost_markup_amount
    remove_column :markings, :labor_cost_markup_amount
    remove_column :markings, :material_cost_markup_amount
    remove_column :markings, :cost_markup_amount

    remove_column :projects, :estimated_fixed_cost
    remove_column :projects, :estimated_raw_fixed_cost
    remove_column :projects, :estimated_unit_cost
    remove_column :projects, :estimated_raw_unit_cost
    remove_column :projects, :estimated_contract_cost
    remove_column :projects, :estimated_raw_contract_cost
    remove_column :projects, :material_cost
    remove_column :projects, :raw_material_cost
    remove_column :projects, :labor_cost
    remove_column :projects, :raw_labor_cost
    remove_column :projects, :contract_cost
    remove_column :projects, :raw_contract_cost
    remove_column :projects, :projected_cost
    remove_column :projects, :raw_projected_cost
    remove_column :projects, :estimated_cost
    remove_column :projects, :estimated_raw_cost
    remove_column :projects, :cost
    remove_column :projects, :raw_cost

    remove_column :components, :estimated_fixed_cost
    remove_column :components, :estimated_unit_cost
    remove_column :components, :estimated_raw_fixed_cost
    remove_column :components, :estimated_raw_unit_cost
    remove_column :components, :estimated_contract_cost
    remove_column :components, :estimated_raw_contract_cost
    remove_column :components, :estimated_component_fixed_cost
    remove_column :components, :estimated_raw_component_fixed_cost
    remove_column :components, :estimated_subcomponent_fixed_cost
    remove_column :components, :estimated_raw_subcomponent_fixed_cost
    remove_column :components, :estimated_component_unit_cost
    remove_column :components, :estimated_raw_component_unit_cost
    remove_column :components, :estimated_subcomponent_unit_cost
    remove_column :components, :estimated_raw_subcomponent_unit_cost
    remove_column :components, :estimated_component_contract_cost
    remove_column :components, :estimated_raw_component_contract_cost
    remove_column :components, :estimated_subcomponent_contract_cost
    remove_column :components, :estimated_raw_subcomponent_contract_cost
    remove_column :components, :estimated_component_cost
    remove_column :components, :estimated_raw_component_cost
    remove_column :components, :estimated_subcomponent_cost
    remove_column :components, :estimated_raw_subcomponent_cost
    remove_column :components, :estimated_cost
    remove_column :components, :estimated_raw_cost


    remove_column :tasks, :estimated_raw_unit_cost
    remove_column :tasks, :estimated_raw_fixed_cost
    remove_column :tasks, :raw_labor_cost
    remove_column :tasks, :raw_material_cost
    remove_column :tasks, :estimated_unit_cost
    remove_column :tasks, :estimated_fixed_cost
    remove_column :tasks, :estimated_cost
    remove_column :tasks, :estimated_raw_cost
    remove_column :tasks, :component_estimated_unit_cost
    remove_column :tasks, :component_estimated_raw_unit_cost
    remove_column :tasks, :component_estimated_fixed_cost
    remove_column :tasks, :component_estimated_raw_fixed_cost
    remove_column :tasks, :component_estimated_cost
    remove_column :tasks, :component_estimated_raw_cost
    remove_column :tasks, :labor_cost
    remove_column :tasks, :material_cost
    remove_column :tasks, :cost
    remove_column :tasks, :raw_cost
    remove_column :tasks, :projected_cost
    remove_column :tasks, :raw_projected_cost
          
    remove_column :fixed_cost_estimates, :cost
    remove_column :unit_cost_estimates, :cost
    remove_column :contracts, :estimated_cost
    remove_column :contracts, :cost
    remove_column :contracts, :raw_cost
    remove_column :contract_costs, :cost
    remove_column :labor_costs, :cost
    remove_column :labor_costs, :raw_cost
    remove_column :labor_cost_lines, :cost
    remove_column :labor_cost_lines, :laborer_pay
    remove_column :material_costs, :cost
    
    remove_column :components, :total_markup
    remove_column :contracts, :total_markup
    remove_column :tasks, :total_markup
    
        
    add_column :markings, :estimated_cost_markup_amount, :float, :default => 0, :null => false
    add_column :markings, :cost_markup_amount, :float, :default => 0, :null => false
    
    add_column :markings, :component_id, :integer
    add_column :contract_costs, :component_id, :integer
    
    
    # Add markings to leaves
    puts "Adding markups for UnitCostEstimate"
    UnitCostEstimate.all.each do |uc|
      uc.markups << uc.component.markups
    end
    puts "Adding markups for FixedCostEstimate"
    FixedCostEstimate.all.each do |fc|
      fc.markups << fc.component.markups
    end
    puts "Adding markups for Contract"
    Contract.all.each do |c|
      c.markups << c.component.markups
    end
    puts "Adding markups for LaborCost"
    LaborCostLine.all.each do |lc|
      lc.markups << lc.labor_set.task.markups
    end
    puts "Adding markups for MaterialCost"
    MaterialCost.all.each do |mc|
      mc.markups << mc.task.markups
    end
    puts "Adding markups for ContractCost"
    ContractCost.includes(:contract).all.each do |cc|
      cc.markups << cc.contract.markups
      cc.update_attributes( :component_id => cc.contract.component_id )
    end
    
    # Re-calculate markup amount
    Marking.includes(:markup, :markupable).all.each do |m|
      puts "Re-calculating marking #{m.id}"
      
      case m.markupable_type
      when 'UnitCostEstimate', 'FixedCostEstimate'
        m.update_attributes( :component_id => m.markupable.component_id, :estimated_cost_markup_amount => m.markup.apply_to(m.markupable, :raw_cost) )
        
      when 'Contract'
        m.update_attributes( :component_id => m.markupable.component_id, :estimated_cost_markup_amount => m.markup.apply_to(m.markupable, :estimated_raw_cost) )
        
      when 'MaterialCost', 'ContractCost'
        m.update_attributes( :component_id => m.markupable.component_id, :cost_markup_amount => m.markup.apply_to(m.markupable, :raw_cost) )

      when 'LaborCostLine'
        m.update_attributes( :component_id => m.markupable.labor_set.component_id, :cost_markup_amount => m.markup.apply_to(m.markupable, :raw_cost) )
        
      end
    end
  end

  def self.down
    add_column :markings, :estimated_unit_cost_markup_amount, :float, :default => 0, :null => false
    add_column :markings, :estimated_fixed_cost_markup_amount, :float, :default => 0, :null => false
    add_column :markings, :estimated_contract_cost_markup_amount, :float, :default => 0, :null => false
    add_column :markings, :estimated_cost_markup_amount, :float, :default => 0, :null => false
    add_column :markings, :labor_cost_markup_amount, :float, :default => 0, :null => false
    add_column :markings, :material_cost_markup_amount, :float, :default => 0, :null => false
    add_column :markings, :cost_markup_amount, :float, :default => 0, :null => false
    
    remove_column :markings, :estimated_cost_markup_amount
    remove_column :markings, :cost_markup_amount
  end
end
