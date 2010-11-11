require File.dirname(__FILE__) + '/../test_helper'

class QuantityTest < ActiveSupport::TestCase
  context "A Quantity" do
    setup do
      @obj = Factory :quantity
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
  end
end
