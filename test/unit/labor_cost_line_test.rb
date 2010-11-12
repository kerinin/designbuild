require File.dirname(__FILE__) + '/../test_helper'

class LaborCostLineTest < ActiveSupport::TestCase
  context "A Labor Cost Line" do
    setup do
      @obj = Factory :labor_cost_line
    end

    teardown do
      LaborCostLine.delete_all
      LaborCost.delete_all
      Task.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.hours
    end
    
    should "require a labor set" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :labor_cost_line, :labor_set => nil
      end
    end
    
    should "require a laborer" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :labor_cost_line, :laborer => nil
      end
    end
  end
end
