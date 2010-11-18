require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  context "A Task" do
    setup do
      @dl1 = Factory :deadline
      @ctr = Factory :contract
      
      @obj = Factory :task, :deadline => @dl1, :contract => @ctr
      
      @q = Factory :quantity, :value => 1
      @fce1 = Factory :fixed_cost_estimate, :task => @obj, :cost => 1
      @fce2 = Factory :fixed_cost_estimate, :task => @obj, :cost => 10
      @uce1 = Factory :unit_cost_estimate, :task => @obj, :quantity => @q, :unit_cost => 100
      @uce2 = Factory :unit_cost_estimate, :task => @obj, :quantity => @q, :unit_cost => 1000
      @lc1 = Factory :labor_cost, :task => @obj, :percent_complete => 10, :date => Date::today
      @lc2 = Factory :labor_cost, :task => @obj, :percent_complete => 20, :date => Date::today + 5
      @lc2 = Factory :labor_cost, :task => @obj, :percent_complete => 30, :date => Date::today - 5
      @mc1 = Factory :material_cost, :task => @obj, :cost => 2
      @mc2 = Factory :material_cost, :task => @obj, :cost => 20
      @mc3 = Factory :material_cost, :task => @obj, :cost => nil
      @mc4 = Factory :material_cost, :task => @obj, :cost => nil
      
      @laborer = Factory :laborer, :bill_rate => 1
      Factory :labor_cost_line, :labor_set => @lc1, :laborer => @laborer, :hours => 200
      Factory :labor_cost_line, :labor_set => @lc1, :laborer => @laborer, :hours => 2000
      Factory :labor_cost_line, :labor_set => @lc2, :laborer => @laborer, :hours => 20000
      Factory :labor_cost_line, :labor_set => @lc2, :laborer => @laborer, :hours => 200000
    end

    teardown do
      Task.delete_all
      Component.delete_all
      Deadline.delete_all
      RelativeDeadline.delete_all
      Contract.delete_all
      FixedCostEstimate.delete_all
      UnitCostEstimate.delete_all
      LaborCost.delete_all
      MaterialCost.delete_all
    end
    
    #-----------------------REQUIRED
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
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
    
    should "allow a relative deadline" do
      assert_nothing_raised do
        @obj.deadline = Factory :relative_deadline
      end
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
       
    should "aggregate costs" do
      assert_contains @obj.costs, @lc1
      assert_contains @obj.costs, @lc2
      assert_contains @obj.costs, @mc1
      assert_contains @obj.costs, @mc2
    end
    
    should "inherit percent complete" do
      assert_equal @obj.percent_complete, 20
    end
    
    #-----------------CALCULATIONS
    
    should "aggregate estimated costs" do
      assert_equal 1111, @obj.estimated_cost
    end
        
    should "return estimated cost nil if no estimates" do
      @obj2 = Factory :task
      assert_equal nil, @obj2.estimated_cost
    end
    
    should "aggregate material costs" do
      assert_equal 22, @obj.material_cost
    end
    
    should "aggregate labor costs" do
      assert_equal 222200, @obj.labor_cost
    end
    
    should "aggregate costs" do
      assert_equal 222222, @obj.cost
    end
    
    should "return cost nil if no costs" do
      @obj2 = Factory :task
      assert_equal nil, @obj2.material_cost
      assert_equal nil, @obj2.labor_cost
      assert_equal nil, @obj2.cost
    end
  end
end
