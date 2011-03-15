require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  context "A Project" do
    setup do
      @obj = Factory :project
      @lab = Factory :laborer, :bill_rate => 1, :project => @obj
      @lab2 = Factory :laborer, :project => @obj
      @s1 = Factory :supplier
      @s2 = Factory :supplier
      @s3 = Factory :supplier
      @task = Factory :task, :project => @obj
      
      @u1 = Factory :user, :projects => [@obj]
      @c1 = Factory :component, :name => 'c1', :project => @obj
        @sc1 = Factory :component, :name => 'sc1', :parent => @c1, :project => @obj
          # .1, assigned task
          @fc1 = Factory :fixed_cost_estimate, :component => @sc1, :raw_cost => 0.1, :task => @task
          @q1 = Factory :quantity, :component => @sc1, :value => 1
          # .03, assigned task
          @uc1 = Factory :unit_cost_estimate, :name => 'uc1', :component => @sc1, :quantity => @q1, :unit_cost => 0.03, :drop => 0, :task => @task #.03
      
      @c2 = Factory :component, :project => @obj
        # 1, unassigned
        @fc2 = Factory :fixed_cost_estimate, :component => @c2, :raw_cost => 1
        @q2 = Factory :quantity, :component => @c2, :value => 1
        # 30, unassigned
        @uc3 = Factory :unit_cost_estimate, :component => @c2, :quantity => @q2, :unit_cost => 30, :drop => 0 #30

      @t1 = Factory :task, :project => @obj
        # 1, assigned t1
        @mc1 = Factory :material_cost, :task => @t1, :raw_cost => 1, :supplier => @s1
        # 10, assigned t1
        @lc1 = Factory :labor_cost, :task => @t1, :percent_complete => 100
          @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :laborer => @lab, :hours => 10
      @t2 = Factory :task, :project => @obj
        # 100, assigned t2
        @mc2 = Factory :material_cost, :task => @t2, :raw_cost => 100, :supplier => @s2
        # 1000, assigned t2
        @lc2 = Factory :labor_cost, :task => @t2, :percent_complete => 100
          @lcl2 = Factory :labor_cost_line, :labor_set => @lc2, :laborer => @lab, :hours => 1000
          
      # t1, t2 100% complete
      
      # 10000, cont1
      @cont1 = Factory :contract, :project => @obj, :component => @c1, :active_bid => Factory(:bid, :raw_cost => 10000)
        @cc1 = Factory :contract_cost, :contract => @cont1, :raw_cost => 10000
        
      # 100000, cont2
      @cont2 = Factory :contract, :project => @obj, :component => @c1, :active_bid => Factory(:bid, :raw_cost => 100000)
        @cc2 = Factory :contract_cost, :contract => @cont2, :raw_cost => 100000
      
      # 1000000, cont3
      @cont3 = Factory :contract, :project => @obj, :component => @c1, :active_bid => Factory(:bid, :raw_cost => 1000000)
        @cc3 = Factory :contract_cost, :contract => @cont3, :raw_cost => 1000000
                
      @dl1 = Factory :deadline, :project => @obj
      @dl2 = Factory :deadline, :project => @obj
      @rdl1 = Factory :deadline, :parent_deadline => @dl1, :interval => 10
      @rdl2 = Factory :deadline, :parent_deadline => @dl2, :interval => 20
      
      [@obj, @task, @c1, @c2, @t1, @t2].each {|i| i.reload}
      
      # 31.13 estimated, plus 1110000 from contracts
      # 1111 actual, plus 1110000 from contracts
      # 1111 actual from tasks has no estimates, so additional
      
      # 1110031.13 estimated
      # 1111111 actual
      # 1111142.13 projected
    end

    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
    end
    
    #--------------------ASSOCIATIONS
    
    should "allow multiple users" do
      assert_contains @obj.users, @u1
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
      assert_contains @obj.unit_cost_estimates.all, @uc3
    end
    
    #---------------------CALCULATIONS
   
    should "aggregate estimated fixed costs" do
      assert_equal 1.1, @obj.reload.estimated_raw_fixed_cost
    end
  
    should "aggregate estimated unit costs" do
      assert_equal 30.03, @obj.reload.estimated_raw_unit_cost
    end

    should "aggregate estimated contract costs" do
      assert_equal 1110000, @obj.reload.estimated_raw_contract_cost
    end
       
    should "aggregate estimated costs" do
      assert_equal 1110031.13, @obj.reload.estimated_raw_cost
    end
    
    should "aggregate material costs" do
      assert_equal 101, @obj.reload.raw_material_cost
    end
    
    should "aggregate labor costs" do
      assert_equal 1010, @obj.reload.raw_labor_cost
    end
    
    should "aggregate contract invoices" do
      assert_equal 1110000, @obj.reload.raw_contract_cost
    end
    
    should "aggregate costs" do
      assert_equal 1111111, @obj.reload.raw_cost
    end
   
    should "aggregated projected cost" do
      assert_equal 1111142.13, @obj.reload.raw_projected_cost
    end

    should "determine projected net" do
      # estimated - projected raw
      @markup = Factory :markup, :percent => 100
      @obj.markups << @markup
      
      assert_equal (@obj.estimated_cost - @obj.raw_projected_cost), @obj.projected_net
    end
  end
end
