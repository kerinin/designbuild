require File.dirname(__FILE__) + '/../test_helper'

class ComponentTest < ActiveSupport::TestCase
  context "A component" do
    setup do
      @tag1 = Factory :tag
      @tag2 = Factory :tag
      
      @parent = Factory :component
      @obj = Factory :component, :tags => [@tag1, @tag2], :parent => @parent
      
      @sub1 = Factory :component, :parent => @obj
      @sub2 = Factory :component, :parent => @obj
      @q1 = Factory :quantity, :component => @obj
      @q2 = Factory :quantity, :component => @obj
      @dq1 = Factory :derived_quantity, :parent_quantity => @q1
      @dq2 = Factory :derived_quantity, :parent_quantity => @q1
      @dq3 = Factory :derived_quantity, :parent_quantity => @q2
      @fc1 = Factory :fixed_cost_estimate, :component => @obj
      @fc2 = Factory :fixed_cost_estimate, :component => @obj
      @uc1 = Factory :unit_cost_estimate, :quantity => @q1
      @uc2 = Factory :unit_cost_estimate, :quantity => @q2
      @uc3 = Factory :unit_cost_estimate, :quantity => @fc1
    end

    teardown do
      Component.delete_all
      Tag.delete_all
      Quantity.delete_all
      DerivedQuantity.delete_all
      FixedCostEstimate.delete_all
      UnitCostEstimate.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
    end
    
    should "have a parent component" do
      assert_equal @obj.parent, @parent
    end
    
    should "require a project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :component, :project => nil
      end
    end
    
    should "have multiple subcomponents" do
      assert_contains @obj.subcomponents, @sub1
      assert_contains @obj.subcomponents, @sub2
    end
    
    should_eventually "have multiple alternates" do
    end
    
    should "have multiple tags" do
      assert_contains @obj.tags, @tag1
      assert_contains @obj.tags, @tag2
      assert_contains @tag1.components, @obj
      assert_contains @tag2.components, @obj
    end
    
    should "have multiple quantities" do
      assert_contains @obj.quantities, @q1
      assert_contains @obj.quantities, @q2
    end
    
    should "have multiple fixed costs" do
      assert_contains @obj.fixed_cost_estimates, @fc1
      assert_contains @obj.fixed_cost_estimates, @fc2
    end
    
    should "aggregate all quantities" do
      assert_contains @obj.all_quantities, @q1
      assert_contains @obj.all_quantities, @q2
      assert_contains @obj.all_quantities, @dq1
      assert_contains @obj.all_quantities, @dq2
      assert_contains @obj.all_quantities, @dq3
    end      
    
    should "have multiple unit costs" do
      assert_contains @obj.unit_cost_estimates, @uc1
      assert_contains @obj.unit_cost_estimates, @uc2
      assert_contains @obj.unit_cost_estimates, @uc3
    end
    
    should "aggregate all costs" do
      assert_contains @obj.cost_estimates, @fc1
      assert_contains @obj.cost_estimates, @fc2
      assert_contains @obj.cost_estimates, @uc1
      assert_contains @obj.cost_estimates, @uc2
      assert_contains @obj.cost_estimates, @uc3
    end
  end
end
