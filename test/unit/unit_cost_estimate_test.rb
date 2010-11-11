require File.dirname(__FILE__) + '/../test_helper'

class UnitCostEstimateTest < ActiveSupport::TestCase
  context "A Unit Cost Estimate" do
    setup do
      @t1 = Factory :task
      
      @obj = Factory :unit_cost_estimate, :task => @t1
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
      assert_not_nil @obj.tax
    end

    should "require a quantity" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :unit_cost_estimate, :quantity => nil
      end
    end
        
    should "allow a task" do
      assert_equal @obj.task, @t1
    end
  end
end
