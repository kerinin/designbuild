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
      @lc1 = Factory :labor_cost, :task => @obj
      @lc2 = Factory :labor_cost, :task => @obj
      @mc1 = Factory :material_cost, :task => @obj
      @mc2 = Factory :material_cost, :task => @obj
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
    
    should "aggregate estimates" do
      assert_contains @obj.estimates, @fce1
      assert_contains @obj.estimates, @fce2     
      assert_contains @obj.estimates, @uce1
      assert_contains @obj.estimates, @uce2
    end
       
    should "aggregate costs" do
      assert_contains @obj.costs, @lc1
      assert_contains @obj.costs, @lc2
      assert_contains @obj.costs, @mc1
      assert_contains @obj.costs, @mc2
    end
    
    #-----------------CALCULATIONS
    
    should "aggregate estimated costs" do
      assert_equal 1111, @obj.estimated_cost
    end
        
    should "return estimated cost nil if no estimates" do
      @obj2 = Factory :task
      assert_equal nil, @obj2.estimated_cost
    end
  end
end
