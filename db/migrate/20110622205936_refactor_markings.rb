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
    self.project = self.markupable.class == Project ? self.markupable : self.markupable.project
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
    
    add_column :markings, :estimated_cost_markup_amount, :float, :default => 0, :null => false
    add_column :markings, :cost_markup_amount, :float, :default => 0, :null => false
    
    
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
    LaborCost.all.each do |lc|
      lc.markups << lc.task.markups
    end
    puts "Adding markups for MaterialCost"
    MaterialCost.all.each do |mc|
      mc.markups << mc.task.markups
    end
    puts "Adding markups for ContractCost"
    ContractCost.all.each do |cc|
      cc.markups << cc.contract.markups
    end
    
    # Re-calculate markup amount
    Marking.includes(:markup, :markupable).all.each do |m|
      puts "Re-calculating markup #{m.id}"
      
      case m.markupable.class
      when UnitCostEstimate, FixedCostEstimate
        m.update_attributes( :estimated_cost_markup_amount, m.markup.apply_to(m.markupable, :raw_cost) )
        m.markupable.update_attributes( :cost, m.markupable.raw_cost + m.estimated_cost_markup_amount )
        
      when Contract
        m.update_attributes( :estimated_cost_markup_amount, m.markup.apply_to(m.markupable, :estimated_raw_cost) )
        m.markupable.update_attributes( :estimated_cost, m.markupable.estimated_raw_cost + m.estimated_cost_markup_amount )
        
      when LaborCost, MaterialCost, ContractCost
        m.update_attributes( :cost_markup_amount, m.markup.apply_to(m.markupable, :raw_cost) )
        m.markupable.update_attributes( :cost, m.markupable.raw_cost + m.cost_markup_amount )
        
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
