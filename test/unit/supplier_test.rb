require File.dirname(__FILE__) + '/../test_helper'

class SupplierTest < ActiveSupport::TestCase
  context "A supplier" do
    setup do
      @obj = Factory :supplier
      
      @mc1 = Factory :material_cost, :supplier => @obj
      @mc2 = Factory :material_cost, :supplier => @obj
    end
    
    teardown do
      Supplier.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
    end
    
    should "allow multiple material costs" do
      assert_contains @obj.material_costs, @mc1
      assert_contains @obj.material_costs, @mc2
    end
  end
end

