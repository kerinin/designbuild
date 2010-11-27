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
      @subsub = Factory :component, :parent => @sub1
      @q1 = Factory :quantity, :component => @obj, :value => 1
      @q2 = Factory :quantity, :component => @obj, :value => 2
      @fc1 = Factory :fixed_cost_estimate, :component => @obj, :raw_cost => 1
      @fc2 = Factory :fixed_cost_estimate, :component => @obj, :raw_cost => 10
      @fc3 = Factory :fixed_cost_estimate, :component => @sub1, :raw_cost => 100000
      @uc1 = Factory :unit_cost_estimate, :quantity => @q1, :unit_cost => 100, :drop => 0 # x1
      @uc2 = Factory :unit_cost_estimate, :quantity => @q2, :unit_cost => 1000, :drop => 0 # x2
    end

    teardown do
      Component.delete_all
      Tag.delete_all
      Quantity.delete_all
      FixedCostEstimate.delete_all
      UnitCostEstimate.delete_all
    end
    
    #---------------REQUIRED
    
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
    
    #-----------------ASSOCIATIONS
    
    should "have multiple subcomponents" do
      assert_contains @obj.children.all, @sub1
      assert_contains @obj.children.all, @sub2
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
    
    should "have multiple unit costs" do
      assert_contains @obj.unit_cost_estimates, @uc1
      assert_contains @obj.unit_cost_estimates, @uc2
    end
    
    should "aggregate all costs" do
      assert_contains @obj.cost_estimates, @fc1
      assert_contains @obj.cost_estimates, @fc2
      assert_contains @obj.cost_estimates, @uc1
      assert_contains @obj.cost_estimates, @uc2
    end
    
    should "return ancestors" do
      assert_contains @subsub.ancestors.all, @sub1
      assert_contains @subsub.ancestors.all, @obj
      assert_contains @subsub.ancestors.all, @parent
    end
    
    should "return descendants" do
      assert_contains @parent.descendants.all, @obj
      assert_contains @parent.descendants.all, @sub1
      assert_contains @parent.descendants.all, @sub2
      assert_contains @parent.descendants.all, @subsub
    end

    #--------------------------CALCULATIONS
    
    should "aggregate estimated costs" do
      assert_equal 102111, @obj.estimated_raw_cost
    end
        
    should "return estimated cost nil if no estimates" do
      @obj2 = Factory :component
      assert_equal nil, @obj2.estimated_raw_cost
    end
  end
end
