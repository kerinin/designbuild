require File.dirname(__FILE__) + '/../test_helper'

class UnitCostEstimateTest < ActiveSupport::TestCase
  context "A Unit Cost Estimate" do
    setup do
      @proj = Factory :project
      @c1 = Factory :component, :project => @proj
      @c2 = Factory :component, :project => @proj
      @t1 = Factory :task, :project => @proj
      @q = Factory :quantity, :value => 10, :component => @c1
      
      @obj = Factory :unit_cost_estimate, :task => @t1, :quantity => @q, :unit_cost => 5
    end

    teardown do
      UnitCostEstimate.delete_all
      Component.delete_all
      Quantity.delete_all
      Task.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.unit_cost
    end

    should "require a quantity" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :unit_cost_estimate, :quantity => nil
      end
    end
        
    should "allow a task" do
      assert_equal @obj.task, @t1
    end
    
    should "not show up in component unassigned costs if has task" do
      assert_does_not_contain @c1.unit_cost_estimates.unassigned.all, @obj
      assert_does_not_contain @c2.unit_cost_estimates.unassigned.all, @obj
    end
    
    should "not show up in project unassigned costs if has task" do
      assert_does_not_contain @proj.unit_cost_estimates.unassigned.all, @obj
    end
    
    should "show up in component unassigned costs if no task" do
      cost = Factory :unit_cost_estimate, :quantity => @q
      assert_contains @c1.unit_cost_estimates.unassigned.all, cost
      assert_does_not_contain @c2.unit_cost_estimates.unassigned.all, cost
    end
    
    should "show up in project unassigned costs if no task" do
      cost = Factory :unit_cost_estimate, :quantity => @q
      assert_contains @proj.unit_cost_estimates.unassigned.all, cost
    end
    
    #------------------CALCULATIONS
    
    should "generate cost" do
      assert_equal 50, @obj.cost
    end
  end
end
