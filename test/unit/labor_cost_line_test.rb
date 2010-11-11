require File.dirname(__FILE__) + '/../test_helper'

class LaborCostLineTest < ActiveSupport::TestCase
  context "A Labor Cost Line" do
    setup do
      @obj = Factory :labor_cost_line
    end

    teardown do
      LaborCostLine.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.hours
    end
  end
end
