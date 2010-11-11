require File.dirname(__FILE__) + '/../test_helper'

class FixedCostEstimateTest < ActiveSupport::TestCase
  context "A Fixed Cost Estimate" do
    setup do
      @obj = Factory :fixed_cost_estimate
    end

    teardown do
      FixedCostEstimate.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.cost
    end
  end
end
