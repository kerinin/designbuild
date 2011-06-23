require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  context "A Task" do
    setup do
      @dl1 = Factory :deadline
      @ctr = Factory :contract
      @component = Factory :component
      
      @obj = Factory :task, :deadline => @dl1, :contract => @ctr
      
      @q = Factory :quantity, :value => 1
      @fce1 = Factory :fixed_cost_estimate, :task => @obj, :component => @component, :raw_cost => 1
      @fce2 = Factory :fixed_cost_estimate, :task => @obj, :component => @component, :raw_cost => 10
      @uce1 = Factory :unit_cost_estimate, :task => @obj, :component => @component, :quantity => @q, :unit_cost => 100, :drop => 0
      @uce2 = Factory :unit_cost_estimate, :task => @obj, :component => @component, :quantity => @q, :unit_cost => 1000, :drop => 0
      @lc1 = Factory :labor_cost, :task => @obj, :percent_complete => 10, :date => Date::today
      @lc2 = Factory :labor_cost, :task => @obj, :percent_complete => 20, :date => Date::today + 5
      @lc2 = Factory :labor_cost, :task => @obj, :percent_complete => 30, :date => Date::today - 5
      @mc1 = Factory :material_cost, :task => @obj, :raw_cost => 2
      @mc2 = Factory :material_cost, :task => @obj, :raw_cost => 20
      @mc3 = Factory :material_cost, :task => @obj, :raw_cost => nil
      @mc4 = Factory :material_cost, :task => @obj, :raw_cost => nil
      
      @laborer = Factory :laborer, :bill_rate => 1
      @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :laborer => @laborer, :hours => 200
      @lcl2 = Factory :labor_cost_line, :labor_set => @lc1, :laborer => @laborer, :hours => 2000
      @lcl3 = Factory :labor_cost_line, :labor_set => @lc2, :laborer => @laborer, :hours => 20000
      @lcl4 = Factory :labor_cost_line, :labor_set => @lc2, :laborer => @laborer, :hours => 200000
      
      [@obj, @lc1, @lc2, @q, @ctr, @dl1, @laborer, @lcl1, @lcl2, @lcl3, @lcl4].each {|i| i.reload}
    end

    should "update labor cost lines when markup added/removed" do
      @obj.markups << Factory(:markup, :percent => 100)
      [@obj, @lcl1, @lcl2].each {|i| i.reload}
      
      assert_equal 400, @lcl1.cost
      assert_equal 4000, @lcl2.cost
      
      @obj.markups = []
      
      [@obj, @lcl1, @lcl2].each {|i| i.reload}
      
      assert_equal 200, @lcl1.cost
      assert_equal 2000, @lcl2.cost
    end
  
    should "update material cost lines when markup added" do
    end
    
    should "update material cost lines when markup removed" do
    end
    
    #-----------------------REQUIRED
 
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.active
    end
    
    should "require a project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :task, :project => nil
      end
    end
    
    should "allow a deadline" do
      assert_equal @obj.deadline, @dl1
      assert_contains @dl1.tasks, @obj
    end
    
    should_eventually "scope active tasks" do
      assert_contains Task.scoped.active.all, @t_inprogress
      assert_does_not_contain Task.scoped.active.all, @t_over_budget
    end
    
    #---------------ASSOCIATIONS
    
    should "allow a contract" do
      assert_equal @obj.contract, @ctr
      assert_contains @ctr.tasks, @obj
    end
    
    should "allow multiple fixed cost estimates" do
      assert_contains @obj.fixed_cost_estimates, @fce1
      assert_contains @obj.fixed_cost_estimates, @fce2
    end
    
    should "allow multiple unit cost estimates" do
      assert_equal @uce1.task, @obj
      assert_contains @obj.unit_cost_estimates, @uce1
      assert_contains @obj.unit_cost_estimates, @uce2
    end
    
    should "allow multiple labor costs" do
      assert_contains @obj.labor_costs, @lc1
      assert_contains @obj.labor_costs, @lc2
    end
    
    should "allow multiple material costs" do
      assert_contains @obj.material_costs, @mc1
      assert_contains @obj.material_costs, @mc2
    end
    
    should "aggregate purchase orders" do
      assert_contains @obj.purchase_orders.all, @mc3
      assert_contains @obj.purchase_orders.all, @mc4
      assert_does_not_contain @obj.purchase_orders.all, @mc1
      assert_does_not_contain @obj.purchase_orders.all, @mc2
    end
    
    should "aggregate completed purchases" do
      assert_contains @obj.completed_purchases.all, @mc1
      assert_contains @obj.completed_purchases.all, @mc2
      assert_does_not_contain @obj.completed_purchases.all, @mc3
      assert_does_not_contain @obj.completed_purchases.all, @mc4
    end  
    
    should "aggregate estimates" do
      assert_contains @obj.cost_estimates, @fce1
      assert_contains @obj.cost_estimates, @fce2     
      assert_contains @obj.cost_estimates, @uce1
      assert_contains @obj.cost_estimates, @uce2
    end
       
    should "aggregate cost objects" do
      assert_contains @obj.costs, @lc1
      assert_contains @obj.costs, @lc2
      assert_contains @obj.costs, @mc1
      assert_contains @obj.costs, @mc2
    end

    should "inherit percent complete" do
      assert_equal 20, @obj.reload.percent_complete
    end
    
    #-----------------CALCULATIONS
   
    should "aggregate estimated costs" do
      assert_equal 1111, @obj.estimated_raw_cost
    end
        
    should "return estimated cost 0 if no estimates" do
      @obj2 = Factory :task
      assert_equal 0, @obj2.estimated_raw_cost
    end
    
    should "aggregate material costs" do
      assert_equal 22, @obj.raw_material_cost
    end

    should_eventually "aggregate material costs with date cutoff" do
    end
        
    should "aggregate labor costs" do
      assert_equal 222200, @obj.raw_labor_cost
    end
    
    should_eventually "aggregate labor costs with date cutoff" do
    end
    
    should "aggregate costs" do
      assert_equal 222222, @obj.raw_cost
    end
    
    should_eventually "aggregate costs with date cutoff" do
    end
    
    should "return cost 0 if no costs" do
      @obj2 = Factory :task
      assert_equal 0, @obj2.raw_material_cost
      assert_equal 0, @obj2.raw_labor_cost
      assert_equal 0, @obj2.raw_cost
    end
     
    should "project costs based on percent complete" do
      @l = Factory :laborer, :bill_rate => 1
      
      @t_start = Factory :task
      Factory :fixed_cost_estimate, :raw_cost => 100, :task => @t_start
      
      @t_inprogress = Factory :task, :active => true
      Factory :fixed_cost_estimate, :raw_cost => 100, :task => @t_inprogress
      @labor_inprogress = Factory :labor_cost, :task => @t_inprogress, :percent_complete => 50
      Factory :labor_cost_line, :labor_set => @labor_inprogress, :laborer => @l, :hours => 50
      
      @t_over_budget = Factory :task, :active => false
      Factory :fixed_cost_estimate, :raw_cost => 100, :task => @t_over_budget
      @labor_over_budget = Factory :labor_cost, :task => @t_over_budget, :percent_complete => 50
      Factory :labor_cost_line, :labor_set => @labor_over_budget, :laborer => @l, :hours => 200
      
      @t_finished_lower = Factory :task
      Factory :fixed_cost_estimate, :raw_cost => 100, :task => @t_finished_lower
      @labor_finished_lower = Factory :labor_cost, :task => @t_finished_lower, :percent_complete => 100
      Factory :labor_cost_line, :labor_set => @labor_finished_lower, :laborer => @l, :hours => 50
      
      @t_finished_higher = Factory :task
      Factory :fixed_cost_estimate, :raw_cost => 100, :task => @t_finished_higher
      @labor_finished_higher = Factory :labor_cost, :task => @t_finished_higher, :percent_complete => 100
      Factory :labor_cost_line, :labor_set => @labor_finished_higher, :laborer => @l, :hours => 200
      
      [@t_start, @t_inprogress, @t_over_budget, @t_finished_lower, @t_finished_higher].each {|i| i.reload}
      
      
      assert_equal 100, @t_start.raw_projected_cost
      assert_equal 100, @t_inprogress.raw_projected_cost
      assert_equal 200, @t_over_budget.raw_projected_cost
      assert_equal 50, @t_finished_lower.raw_projected_cost
      assert_equal 200, @t_finished_higher.raw_projected_cost
    end
    
    should "determine projected_net" do
      assert_equal 1111, @obj.estimated_raw_cost
      assert_equal 1111, @obj.estimated_cost
      assert_equal 222222, @obj.raw_projected_cost
      
      # estimated - projected net
      @markup = Factory :markup, :percent => 100
      @component.markups << @markup
      @obj.reload
      assert_equal 2222, @obj.estimated_cost
      
      assert_equal @obj.estimated_cost - @obj.raw_projected_cost, @obj.projected_net
      assert_equal (2222 - 222222), @obj.projected_net
    end
 
    should "de-associate costs when destroyed" do
      @obj.destroy
      
      assert_equal nil, @fce1.reload.task_id
      assert_equal nil, @fce2.reload.task_id
      assert_equal nil, @uce1.reload.task_id
      assert_equal nil, @uce2.reload.task_id
    end
  end
end
