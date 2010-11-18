require File.dirname(__FILE__) + '/../test_helper'

class QuantityTest < ActiveSupport::TestCase
  context "A Quantity" do
    setup do
      @obj = Factory :quantity
      
      @uc1 = Factory :unit_cost_estimate, :quantity => @obj
      @uc2 = Factory :unit_cost_estimate, :quantity => @obj
    end

    teardown do
      Quantity.delete_all
      Component.delete_all
      UnitCostEstimate.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.value
      assert_not_nil @obj.unit
    end
    
    should "require a component" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :quantity, :component => nil
      end
    end
    
    should "allow multiple unit costs" do
      assert_contains @obj.unit_cost_estimates, @uc1
      assert_contains @obj.unit_cost_estimates, @uc2
    end
  end
end
