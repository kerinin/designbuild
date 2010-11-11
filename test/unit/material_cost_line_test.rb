require File.dirname(__FILE__) + '/../test_helper'

class MaterialCostLineTest < ActiveSupport::TestCase
  context "A Material Cost Line" do
    setup do
      @obj = Factory :material_cost_line
    end

    teardown do
      MaterialCostLine.delete_all
      MaterialCost.delete_all
      Task.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.quantity
    end
  end
end
