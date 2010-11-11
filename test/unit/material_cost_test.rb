require File.dirname(__FILE__) + '/../test_helper'

class MaterialCostTest < ActiveSupport::TestCase
  context "A Material Cost" do
    setup do
      @obj = Factory :material_cost
    end

    teardown do
      MaterialCost.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.date
      assert_not_nil @obj.amount
    end
  end
end
