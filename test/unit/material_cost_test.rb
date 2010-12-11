require File.dirname(__FILE__) + '/../test_helper'

class MaterialCostTest < ActiveSupport::TestCase
  context "A Material Cost" do
    setup do
      @proj1 = Factory :project
      @proj2 = Factory :project
      @task1 = Factory :task, :project => @proj1
      @task2 = Factory :task, :project => @proj2
      
      @obj = Factory :material_cost
      @o1 = Factory :material_cost, :task => @task1, :raw_cost => nil
      @o2 = Factory :material_cost, :task => @task1, :raw_cost => nil
      @o3 = Factory :material_cost, :task => @task2
      @o4 = Factory :material_cost, :task => @task2
      
      @li1 = Factory :material_cost_line, :material_set => @obj
      @li2 = Factory :material_cost_line, :material_set => @obj
      
      [@obj, @proj1, @proj2, @task1, @task2].each {|i| i.reload}
    end

    teardown do
      MaterialCost.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.date
      assert_not_nil @obj.raw_cost
    end
    
    should "require a task" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :material_cost, :task => nil
      end
    end
    
    should "require a supplier" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :material_cost, :supplier => nil
      end
    end
    
    should "scope to purchase orders" do
      assert_contains MaterialCost.purchase_order.all, @o1
      assert_contains MaterialCost.purchase_order.all, @o2
      assert_does_not_contain MaterialCost.purchase_order.all, @o3
      assert_does_not_contain MaterialCost.purchase_order.all, @o4
    end
    
    should "allow multiple line items" do
      assert_contains @obj.line_items, @li1
      assert_contains @obj.line_items, @li2
    end
  end
end
