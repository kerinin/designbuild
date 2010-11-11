require File.dirname(__FILE__) + '/../test_helper'

class DerivedQuantityTest < ActiveSupport::TestCase
  context "A Derived Quantity" do
    setup do
      @obj = Factory :derived_quantity
    end

    teardown do
      DerivedQuantity.delete_all
      Quantity.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.multiplier
    end
    
    should "require a parent quantity and component" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :derived_quantity, :parent_quantity => nil
      end
      #assert_raise ActiveRecord::RecordInvalid do
      #  Factory :derived_quantity, :component => nil
      #end
    end
    
    should "inherit component" do
      assert_not_nil @obj.component
    end
  end
end
