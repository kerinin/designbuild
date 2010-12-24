include AddOrNil
  
class AddLaborCostLineCosts < ActiveRecord::Migration
  class Laborer < ActiveRecord::Base
    has_many :labor_cost_lines, :dependent => :destroy
  end
  
  class LaborCost < ActiveRecord::Base
    belongs_to :task, :inverse_of => :labor_costs
    
    has_many :line_items, :class_name => "LaborCostLine", :foreign_key => :labor_set_id, :dependent => :destroy
    
    def total_markup
      self.task.total_markup unless self.task.blank?
    end
  end
  
  class Task < ActiveRecord::Base
    has_many :labor_costs, :order => 'date DESC', :dependent => :destroy
  end
  
  class LaborCostLine < ActiveRecord::Base
    include MarksUp
    
    belongs_to :laborer, :inverse_of => :labor_cost_lines
    belongs_to :labor_set, :class_name => "LaborCost", :inverse_of => :line_items
    
    before_validation :set_costs
    
    def total_markup
      self.labor_set.total_markup unless self.labor_set.blank?
    end
  
    def set_costs
      self.raw_cost = self.hours * self.laborer.bill_rate unless ( self.laborer.blank? || self.laborer.destroyed? )
      self.laborer_pay = self.hours * self.laborer.pay_rate unless ( self.laborer.blank? || self.laborer.destroyed? || self.laborer.pay_rate.nil? )
      
      self.cost = mark_up :raw_cost
    end
  end
  
  def self.up
    add_column :labor_cost_lines, :cost, :float
    add_column :labor_cost_lines, :raw_cost, :float
    add_column :labor_cost_lines, :laborer_pay, :float
    add_column :labor_cost_lines, :project_id, :integer
    add_column :labor_costs, :project_id, :integer
    
    LaborCostLine.all.each {|lc| lc.project_id = lc.labor_set.task.project_id; lc.save!}
    LaborCost.all.each {|l| l.project_id = l.task.project_id; l.save!}
  end

  def self.down
    remove_column :labor_cost_lines, :cost
    remove_column :labor_cost_lines, :raw_cost
    remove_column :labor_cost_lines, :laborer_pay
    remove_column :labor_cost_lines, :project_id
    remove_column :labor_costs, :project_id
  end
end
