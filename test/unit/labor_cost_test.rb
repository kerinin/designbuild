require File.dirname(__FILE__) + '/../test_helper'

class LaborCostTest < ActiveSupport::TestCase
  context "A Labor Cost" do
    setup do
      @laborer = Factory :laborer, :bill_rate => 1
      
      @obj = Factory :labor_cost
      
      @li1 = Factory :labor_cost_line, :labor_set => @obj, :laborer => @laborer, :hours => 2
      @li2 = Factory :labor_cost_line, :labor_set => @obj, :laborer => @laborer, :hours => 20
    end

    teardown do
      LaborCost.delete_all
      Task.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.date
    end
    
    should "require a task" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :labor_cost, :task => nil
      end
    end
    
    should "allow multiple line items" do
      assert_contains @obj.line_items, @li1
      assert_contains @obj.line_items, @li2
    end
    
    #----------------------CALCULATIONS
    
    should "aggregate costs" do
      assert_equal 22, @obj.cost
    end
    
    should "return cost nil if no line items" do
      @obj2 = Factory :labor_cost
      assert_equal nil, @obj2.cost
    end
  end
end
