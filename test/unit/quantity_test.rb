require File.dirname(__FILE__) + '/../test_helper'

class QuantityTest < ActiveSupport::TestCase
  context "A Quantity" do
    setup do
      @obj = Factory :quantity
    end

    teardown do
      Quantity.delete_all
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
  end
end
