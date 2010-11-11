require File.dirname(__FILE__) + '/../test_helper'

class QuantityTest < ActiveSupport::TestCase
  context "A Quantity" do
    setup do
      @obj = Factory :quantity
      
      @dq1 = Factory :derived_quantity, :parent_quantity => @obj
      @dq2 = Factory :derived_quantity, :parent_quantity => @obj
      @uc1 = Factory :unit_cost_estimate, :quantity => @obj
      @uc2 = Factory :unit_cost_estimate, :quantity => @obj
    end

    teardown do
      Quantity.delete_all
      Component.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.value
      assert_not_nil @obj.unit
      assert_not_nil @obj.drop
    end
    
    should "require a component" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :quantity, :component => nil
      end
    end
    
    should "have multiple derived quantities" do
      assert_contains @obj.derived_quantities, @dq1
      assert_contains @obj.derived_quantities, @dq2
    end
    
    should "have multiple unit costs" do
      assert_contains @obj.unit_cost_estimates, @uc1
      assert_contains @obj.unit_cost_estimates, @uc2
    end
  end
end
