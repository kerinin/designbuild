class NewInvoicing < ActiveRecord::Migration
  class Project < ActiveRecord::Base
    has_many :material_costs
    has_many :labor_costs
  end
  
  class FixedCostEstimate < ActiveRecord::Base
    belongs_to :task
    belongs_to :component
  end
  
  class UnitCostEstimate < ActiveRecord::Base
    belongs_to :task
    belongs_to :component
  end
  
  class Task < ActiveRecord::Base
    has_many :material_costs
    has_many :labor_costs
    has_many :fixed_cost_estimates
    has_many :unit_cost_estimates
  end
  
  class Component < ActiveRecord::Base
    has_many :fixed_cost_estimates
    has_many :unit_cost_estimates
  end
  
  class MaterialCost < ActiveRecord::Base
    belongs_to :project
    belongs_to :task
    
    def auto_assign_component
      # If the task has no estimated costs, it can't have a component association
      return if self.task.fixed_cost_estimates.empty? && self.task.unit_cost_estimates.empty?

      components = Component.scoped.includes(:fixed_cost_estimates, :unit_cost_estimates)

      # if the task has costs associated with it and they're all from the same component, assign the component to this cost
      components = components.where('fixed_cost_estimates.task_id = ?', self.task_id) unless self.task.fixed_cost_estimates.empty?
      components = components.where('unit_cost_estimates.task_id = ?', self.task_id) unless self.task.unit_cost_estimates.empty?

      self.component_id = components.first.id if components.count == 1
    end
  end

  class LaborCost < ActiveRecord::Base
    belongs_to :project
    belongs_to :task
    
    def auto_assign_component
      # If the task has no estimated costs, it can't have a component association
      return if self.task.fixed_cost_estimates.empty? && self.task.unit_cost_estimates.empty?

      components = Component.scoped.includes(:fixed_cost_estimates, :unit_cost_estimates)

      # if the task has costs associated with it and they're all from the same component, assign the component to this cost
      components = components.where('fixed_cost_estimates.task_id = ?', self.task_id) unless self.task.fixed_cost_estimates.empty?
      components = components.where('unit_cost_estimates.task_id = ?', self.task_id) unless self.task.unit_cost_estimates.empty?

      self.component_id = components.first.id if components.count == 1
    end
  end
    
  def self.up
    add_column :invoice_lines, :component_id, :integer
    add_column :invoice_lines, :invoiced, :float, :default => 0
    add_column :invoice_lines, :retainage, :float, :default => 0
    
    add_column :payment_lines, :component_id, :integer
    add_column :payment_lines, :paid, :float, :default => 0
    add_column :payment_lines, :retained, :float, :default => 0
    
    add_column :material_costs, :project_id, :integer
    add_column :material_costs, :component_id, :integer
    
    add_column :labor_costs, :component_id, :integer
    
    MaterialCost.all.each do |mc|
      mc.project_id = mc.task.project_id
      mc.auto_assign_component
      mc.save!
    end
    
    LaborCost.all.each do |lc|
      lc.auto_assign_component
      lc.save!
    end
  end

  def self.down
    remove_column :invoice_lines, :component_id, :integer
    remove_column :invoice_lines, :invoiced
    remove_column :invoice_lines, :retainage
    
    remove_column :payment_lines, :component_id
    remove_column :payment_lines, :paid
    remove_column :payment_lines, :retained
    
    remove_column :material_costs, :project_id
    remove_column :material_costs, :component_id
    
    remove_column :labor_costs, :component_id
  end
end
