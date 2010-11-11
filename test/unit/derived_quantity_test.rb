require File.dirname(__FILE__) + '/../test_helper'

class DerivedQuantityTest < ActiveSupport::TestCase
  context "A Derived Quantity" do
    setup do
      @obj = Factory :derived_quantity
    end

    teardown do
      DerivedQuantity.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.multiplier
    end
  end
end
