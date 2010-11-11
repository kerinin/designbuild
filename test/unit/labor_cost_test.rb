require File.dirname(__FILE__) + '/../test_helper'

class LaborCostTest < ActiveSupport::TestCase
  context "A Labor Cost" do
    setup do
      @obj = Factory :labor_cost
    end

    teardown do
      LaborCost.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.date
    end
  end
end
