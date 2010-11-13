require File.dirname(__FILE__) + '/../test_helper'

class FixedCostEstimateTest < ActiveSupport::TestCase
  context "A Fixed Cost Estimate" do
    setup do
      @proj = Factory :project
      @c1 = Factory :component, :project => @proj
      @c2 = Factory :component, :project => @proj
      @t1 = Factory :task, :project => @proj

      @obj = Factory :fixed_cost_estimate, :task => @t1
    end

    teardown do
      FixedCostEstimate.delete_all
      Component.delete_all
      Task.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.cost
    end
    
    should "require a component" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :fixed_cost_estimate, :component => nil
      end
    end
    
    should "allow a task" do
      assert_equal @obj.task, @t1
    end
    
    should "not show up in component unassigned costs if has task" do
      assert_does_not_contain @c1.fixed_cost_estimates.unassigned, @obj
      assert_does_not_contain @c2.fixed_cost_estimates.unassigned, @obj
    end
    
    should "not show up in project unassigned costs if has task" do
      assert_does_not_contain @proj.fixed_cost_estimates.unassigned, @obj
    end
    
    should "show up in component unassigned costs if no task" do
      cost = Factory :unit_cost_estimate, :quantity => @q
      assert_contains @c1.fixed_cost_estimates.unassigned, @obj
      assert_does_not_contain @c2.fixed_cost_estimates.unassigned, @obj
    end
    
    should "show up in project unassigned costs if no task" do
      cost = Factory :unit_cost_estimate, :quantity => @q
      assert_contains @c1.fixed_cost_estimates.unassigned, @obj
    end
  end
end
