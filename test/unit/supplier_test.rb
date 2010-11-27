require File.dirname(__FILE__) + '/../test_helper'

class SupplierTest < ActiveSupport::TestCase
  context "A supplier" do
    setup do
      @obj = Factory :supplier
      
      @mc1 = Factory :material_cost, :supplier => @obj
      @mc2 = Factory :material_cost, :supplier => @obj
      @mc3 = Factory :material_cost, :supplier => @obj, :raw_cost => nil
      @mc4 = Factory :material_cost, :supplier => @obj, :raw_cost => nil
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
    
    should_eventually "require a project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :supplier, :project => nil
      end
    end
    
    should "allow multiple material costs" do
      assert_contains @obj.material_costs, @mc1
      assert_contains @obj.material_costs, @mc2
    end
    
    should "aggregate purchase orders" do
      assert_contains @obj.purchase_orders.all, @mc3
      assert_contains @obj.purchase_orders.all, @mc4
      assert_does_not_contain @obj.purchase_orders.all, @mc1
      assert_does_not_contain @obj.purchase_orders.all, @mc2
    end
    
    should "aggregate completed purchases" do
      assert_contains @obj.completed_purchases.all, @mc1
      assert_contains @obj.completed_purchases.all, @mc2
      assert_does_not_contain @obj.completed_purchases.all, @mc3
      assert_does_not_contain @obj.completed_purchases.all, @mc4
    end
  end
end

