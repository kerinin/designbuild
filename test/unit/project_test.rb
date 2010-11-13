require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  context "A Project" do
    setup do
      @obj = Factory :project
      @lab = Factory :laborer, :bill_rate => 1, :project => @obj
      @lab2 = Factory :laborer, :project => @obj
      
      @u1 = Factory :user, :projects => [@obj]
      #@u2 = Factory :user, :projects => [@obj]
      @c1 = Factory :component, :project => @obj
        @sc1 = Factory :component, :parent => @c1, :project => @obj
          @fc1 = Factory :fixed_cost_estimate, :component => @sc1, :cost => 0.1
          @q1 = Factory :quantity, :component => @sc1, :value => 1
          @dq1 = Factory :derived_quantity, :parent_quantity => @q1, :multiplier => 2 # 2
          @uc1 = Factory :unit_cost_estimate, :component => @sc1, :quantity => @q1, :unit_cost => 0.03 #.03
          @uc2 = Factory :unit_cost_estimate, :component => @sc1, :quantity => @dq1, :unit_cost => 0.003 #.006
        
      @c2 = Factory :component, :project => @obj
        @fc2 = Factory :fixed_cost_estimate, :component => @c2, :cost => 1
        @q2 = Factory :quantity, :component => @c2, :value => 1
        @dq2 = Factory :derived_quantity, :parent_quantity => @q2, :multiplier => 2 # 2
        @uc3 = Factory :unit_cost_estimate, :component => @c2, :quantity => @q2, :unit_cost => 30 #30
        @uc4 = Factory :unit_cost_estimate, :component => @c2, :quantity => @dq2, :unit_cost => 300 #600

      @t1 = Factory :task, :project => @obj
        @mc1 = Factory :material_cost, :task => @t1, :cost => 1
        @lc1 = Factory :labor_cost, :task => @t1
          @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :laborer => @lab, :hours => 10
      @t2 = Factory :task, :project => @obj
        @mc2 = Factory :material_cost, :task => @t2, :cost => 100
        @lc2 = Factory :labor_cost, :task => @t2
          @lcl2 = Factory :labor_cost_line, :labor_set => @lc2, :laborer => @lab, :hours => 1000
          
      @cont1 = Factory :contract, :project => @obj
        @cc1 = Factory :contract_cost, :contract => @cont1, :cost => 10000
      @cont2 = Factory :contract, :project => @obj
        @cc2 = Factory :contract_cost, :contract => @cont2, :cost => 100000
        
      @dl1 = Factory :deadline, :project => @obj
      @dl2 = Factory :deadline, :project => @obj
      @rdl1 = Factory :relative_deadline, :parent_deadline => @dl1
      @rdl2 = Factory :relative_deadline, :parent_deadline => @dl2
    end

    teardown do
      Project.delete_all
      User.delete_all
      Component.delete_all
      Task.delete_all
      Contract.delete_all
      Deadline.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
    end
    
    #--------------------ASSOCIATIONS
    
    should "allow multiple laborers" do
      assert_contains @obj.laborers, @lab
      assert_contains @obj.laborers, @lab2
    end
    
    should "allow multiple users" do
      assert_contains @obj.users, @u1
      #assert_contains @obj.users, @u2
    end
    
    should "allow multiple components" do
      assert_contains @obj.components, @c1
      assert_contains @obj.components, @c2
    end
    
    should "allow multiple tasks" do
      assert_contains @obj.tasks, @t1
      assert_contains @obj.tasks, @t2
    end
    
    should "allow multiple contracts" do
      assert_contains @obj.contracts, @cont1
      assert_contains @obj.contracts, @cont2
    end
    
    should_eventually "allow multiple deadlines" do
      assert_contains @obj.deadlines, @dl1
      assert_contains @obj.deadlines, @dl2
      assert_contains @obj.deadlines, @rdl1
      assert_contains @obj.deadlines, @rdl2
    end
    
    should "distribute to sub-components" do
      @sub = Factory :component, :parent => @c1, :project => nil
      assert_equal @obj, @sub.project
    end
    
    should "inherit fixed cost estimates" do
      assert_contains @obj.fixed_cost_estimates.all, @fc1
      assert_contains @obj.fixed_cost_estimates.all, @fc2
    end
    
    should "inherit unit cost estimates" do
      assert_contains @obj.unit_cost_estimates.all, @uc1
      assert_contains @obj.unit_cost_estimates.all, @uc2
      assert_contains @obj.unit_cost_estimates.all, @uc3
      assert_contains @obj.unit_cost_estimates.all, @uc4
    end
    
    #---------------------CALCULATIONS
    
    should "aggregate estimated fixed costs" do
      assert_equal 1.1, @obj.estimated_fixed_cost
    end
    
    should "aggregate estimated unit costs" do
      assert_equal 630.036, @obj.estimated_unit_cost
    end
    
    should "aggregate estimated costs" do
      assert_equal 631.136, @obj.estimated_cost
    end
    
    should "aggregate material costs" do
      assert_equal 101, @obj.material_cost
    end
    
    should "aggregate labor costs" do
      assert_equal 1010, @obj.labor_cost
    end
    
    should "aggregate contract costs" do
      assert_equal 110000, @obj.contract_cost
    end
    
    should "aggregate costs" do
      assert_equal 111111, @obj.cost
    end
  end
end
