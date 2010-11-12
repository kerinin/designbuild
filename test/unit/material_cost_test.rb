require File.dirname(__FILE__) + '/../test_helper'

class MaterialCostTest < ActiveSupport::TestCase
  context "A Material Cost" do
    setup do
      @obj = Factory :material_cost
      
      @li1 = Factory :material_cost_line, :material_set => @obj
      @li2 = Factory :material_cost_line, :material_set => @obj
    end

    teardown do
      MaterialCost.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.date
      assert_not_nil @obj.cost
    end
    
    should "require a task" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :material_cost, :task => nil
      end
    end
    
    should "allow multiple line items" do
      assert_contains @obj.line_items, @li1
      assert_contains @obj.line_items, @li2
    end
  end
end
