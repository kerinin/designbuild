require File.dirname(__FILE__) + '/../test_helper'

class InvoiceableTest < ActiveSupport::TestCase
  context "Given a project" do
    setup do
      @project = Factory :project
      @component1 = @project.components.create! :name => 'component1'
      @task1 = @project.tasks.create! :name => 'task1'
      @component2 = @project.components.create! :name => 'component2'
      @task2 = @project.tasks.create! :name => 'task2'
      
      @l = Factory :laborer, :bill_rate => 1
      @lc = @task1.labor_costs.create! :percent_complete => 50, :date => Date::today
      @lcl = @lc.line_items.create! :laborer => @l, :hours => 20
      @mc = @task1.material_costs.create! :raw_cost => 30, :date => Date::today, :supplier => Factory(:supplier)
      
      @lc2 = @task1.labor_costs.create! :percent_complete => 50, :date => Date::today - 10
      @lcl2 = @lc2.line_items.create! :laborer => @l, :hours => 20
      @mc2 = @task1.material_costs.create! :raw_cost => 30, :date => Date::today - 10, :supplier => Factory(:supplier)
    end
    
    @fixed = Proc.new { |project, component1, task1, component2, task2, l, lc, lcl, mc|
      @fce1 = component1.fixed_cost_estimates.create! :name => 'fixed cost estimate 1', :raw_cost => 1
      task1.fixed_cost_estimates << @fce1
      @fce2 = component1.fixed_cost_estimates.create! :name => 'fixed cost estimate 2', :raw_cost => 10
      @fce3 = component2.fixed_cost_estimates.create! :name => 'fixed cost estimate 3', :raw_cost => 100
      task2.fixed_cost_estimates << @fce3
      @fce4 = component1.fixed_cost_estimates.create! :name => 'fixed cost estimate 4', :raw_cost => 100
            
      [@fce1, @fce2, @fce3, @fce4]
    }
    
    @unit = Proc.new { |project, component1, task1, component2, task2, l, lc, lcl, mc|
      @q = Factory :quantity, :component => component1, :value => 1
      @uce1 = component1.unit_cost_estimates.create! :name => 'unit cost estimate 1', :unit_cost => 2, :quantity => @q
      task1.unit_cost_estimates << @uce1
      @uce2 = component1.unit_cost_estimates.create! :name => 'unit cost estimate 2', :unit_cost => 20, :quantity => @q
      @uce3 = component2.unit_cost_estimates.create! :name => 'unit cost estimate 3', :unit_cost => 200, :quantity => @q
      task1.unit_cost_estimates << @uce3
      @uce4 = component1.unit_cost_estimates.create! :name => 'unit cost estimate 4', :unit_cost => 2000, :quantity => @q
      
      [@uce1, @uce2, @uce3, @uce4]
    }
    
    @contract = Proc.new { |project, component1, task1, component2, task2, l, lc, lcl, mc|
      @contract1 = project.contracts.create! :name => 'contract 1', :component => component1
      @contract1.active_bid = Factory( :bid, :contract => @contract1, :raw_cost => 3 )
      component1.contracts << @contract1
      @contract2 = project.contracts.create! :name => 'contract 2', :component => component2
      @contract2.active_bid = Factory( :bid, :contract => @contract1, :raw_cost => 30 )
      component2.contracts << @contract2
      @contract3 = project.contracts.create! :name => 'contract 3', :component => component2
      @contract3.active_bid = Factory( :bid, :contract => @contract1, :raw_cost => 300 )
      component2.contracts << @contract3
      
      @contract1.costs.create! :raw_cost => 500, :date => Date::today
      @contract1.costs.create! :raw_cost => 500, :date => Date:: today - 10
      
      [@contract1, @contract2, @contract3]
    }
    
    # NOTE: this has been completely refactored and has ZERO test coverage!!!
  end
end
