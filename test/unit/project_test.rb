require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
=begin
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
      #@u2 = Factory :user, :projects => [@obj]
      @c1 = Factory :component, :name => 'c1', :project => @obj
        @sc1 = Factory :component, :name => 'sc1', :parent => @c1, :project => @obj
          @fc1 = Factory :fixed_cost_estimate, :component => @sc1, :raw_cost => 0.1, :task => @task
          @q1 = Factory :quantity, :component => @sc1, :value => 1
          @uc1 = Factory :unit_cost_estimate, :name => 'uc1', :component => @sc1, :quantity => @q1, :unit_cost => 0.03, :drop => 0, :task => @task #.03
      
      @c2 = Factory :component, :project => @obj
        @fc2 = Factory :fixed_cost_estimate, :component => @c2, :raw_cost => 1
        @q2 = Factory :quantity, :component => @c2, :value => 1
        @uc3 = Factory :unit_cost_estimate, :component => @c2, :quantity => @q2, :unit_cost => 30, :drop => 0 #30

      @t1 = Factory :task, :project => @obj
        @mc1 = Factory :material_cost, :task => @t1, :raw_cost => 1, :supplier => @s1
        @lc1 = Factory :labor_cost, :task => @t1
          @lcl1 = Factory :labor_cost_line, :labor_set => @lc1, :laborer => @lab, :hours => 10
      @t2 = Factory :task, :project => @obj
        @mc2 = Factory :material_cost, :task => @t2, :raw_cost => 100, :supplier => @s2
        @lc2 = Factory :labor_cost, :task => @t2
          @lcl2 = Factory :labor_cost_line, :labor_set => @lc2, :laborer => @lab, :hours => 1000
          
      @cont1 = Factory :contract, :project => @obj, :active_bid => Factory(:bid, :raw_cost => 10000)
        @cc1 = Factory :contract_cost, :contract => @cont1, :raw_cost => 10000
      @cont2 = Factory :contract, :project => @obj, :active_bid => Factory(:bid, :raw_cost => 100000)
        @cc2 = Factory :contract_cost, :contract => @cont2, :raw_cost => 100000
        
      @dl1 = Factory :deadline, :project => @obj
      @dl2 = Factory :deadline, :project => @obj
      @rdl1 = Factory :deadline, :parent_deadline => @dl1, :interval => 10
      @rdl2 = Factory :deadline, :parent_deadline => @dl2, :interval => 20
    end

    teardown do
      Project.delete_all
      User.delete_all
      Component.delete_all
      Task.delete_all
      Contract.delete_all
      Deadline.delete_all
      Quantity.delete_all
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
      assert_contains @obj.unit_cost_estimates.all, @uc3
    end
    
    #---------------------CALCULATIONS
   
    should "aggregate estimated fixed costs" do
      assert_equal 1.1, @obj.estimated_raw_fixed_cost
    end
  
    should "aggregate estimated unit costs" do
      assert_equal 30.03, Project.find(@obj.id).estimated_raw_unit_cost
    end
   
    should "aggregate estimated costs" do
      assert_equal 31.13, @obj.estimated_raw_cost
    end
    
    should "aggregate material costs" do
      assert_equal 101, @obj.raw_material_cost
    end
    
    should "aggregate labor costs" do
      assert_equal 1010, @obj.raw_labor_cost
    end
    
    should "aggregate contract invoices" do
      assert_equal 110000, @obj.reload.raw_contract_invoiced
    end
    
    should "aggregate costs" do
      assert_equal 111111, @obj.reload.raw_cost
    end
  end
=end 
  context "A project w/ caching" do
    setup do
      @project = Factory :project, :markups => [ Factory :markup, :percent => 100 ], :name => 'project'
      @component = Factory :component, :project => @project, :name => 'component'
      @subcomponent = Factory :component, :parent => @component, :name => 'subcomponent'
      @task = Factory :task, :project => @project
      @contract = Factory :contract, :project => @project
      @laborer = Factory :laborer, :bill_rate => 1
    end
    
    should "reflect root unit costs" do
      @q = Factory :quantity, :component => @component, :value => 1
      @uc = Factory :unit_cost_estimate, :component => @component, :quantity => @q, :unit_cost => 100, :drop => 0
      
      assert_equal 100, @project.reload.estimated_raw_unit_cost
      assert_equal 200, @project.reload.estimated_unit_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @uc.destroy
      
      assert_equal nil, @project.reload.estimated_raw_unit_cost
      assert_equal nil, @project.reload.estimated_unit_cost
      assert_equal nil, @project.reload.estimated_raw_cost
      assert_equal nil, @project.reload.estimated_cost
    end
    
    should "reflect subcomponent unit costs" do
      @q = Factory :quantity, :component => @subcomponent, :value => 1
      @uc = Factory :unit_cost_estimate, :component => @subcomponent, :quantity => @q, :unit_cost => 100, :drop => 0, :name => 'unit cost'
      
      assert_equal 100, @project.reload.estimated_raw_unit_cost
      assert_equal 200, @project.reload.estimated_unit_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @uc.destroy
      
      assert_equal nil, @project.reload.estimated_raw_unit_cost
      assert_equal nil, @project.reload.estimated_unit_cost
      assert_equal nil, @project.reload.estimated_raw_cost
      assert_equal nil, @project.reload.estimated_cost
    end
    
    should "reflect root fixed costs" do
      @fc = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 100
      
      assert_equal 100, @project.reload.estimated_raw_fixed_cost
      assert_equal 200, @project.reload.estimated_fixed_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @fc.destroy
      
      assert_equal nil, @project.reload.estimated_raw_fixed_cost
      assert_equal nil, @project.reload.estimated_fixed_cost
      assert_equal nil, @project.reload.estimated_raw_cost
      assert_equal nil, @project.reload.estimated_cost
    end
    
    should "reflect subcomponent fixed costs" do
      @fc = Factory :fixed_cost_estimate, :component => @subcomponent, :raw_cost => 100
      
      assert_equal 100, @project.reload.estimated_raw_fixed_cost
      assert_equal 200, @project.reload.estimated_fixed_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @fc.destroy
      
      assert_equal nil, @project.reload.estimated_raw_fixed_cost
      assert_equal nil, @project.reload.estimated_fixed_cost
      assert_equal nil, @project.reload.estimated_raw_cost
      assert_equal nil, @project.reload.estimated_cost
    end
    
    should "reflect task labor costs" do
      @lc = Factory :labor_cost, :task => @task
      @ll = Factory :labor_cost_line, :labor_set => @lc, :laborer => @laborer, :hours => 100
      
      assert_equal 100, @project.reload.raw_labor_cost
      assert_equal 200, @project.reload.labor_cost
      assert_equal 100, @project.reload.raw_cost
      assert_equal 200, @project.reload.cost
      
      @lc.destroy
      
      assert_equal nil, @project.reload.raw_labor_cost
      assert_equal nil, @project.reload.labor_cost
      assert_equal nil, @project.reload.raw_cost
      assert_equal nil, @project.reload.cost
    end
    
    should "reflect task material costs" do
      @mc = Factory :material_cost, :task => @task, :raw_cost => 100
      
      assert_equal 100, @project.reload.raw_material_cost
      assert_equal 200, @project.reload.material_cost
      assert_equal 100, @project.reload.raw_cost
      assert_equal 200, @project.reload.cost
      
      @mc.destroy
      
      assert_equal nil, @project.reload.raw_material_cost
      assert_equal nil, @project.reload.material_cost
      assert_equal nil, @project.reload.raw_cost
      assert_equal nil, @project.reload.cost
    end
    
    should "reflect contract cost" do
      @bid = Factory :bid, :raw_cost => 100, :contract => @contract
      @contract.active_bid = @bid
      @contract.save
      
      assert_equal 100, @project.reload.raw_contract_cost
      assert_equal 200, @project.reload.contract_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @bid.destroy
      
      assert_equal nil, @project.reload.raw_contract_cost
      assert_equal nil, @project.reload.contract_cost
      assert_equal nil, @project.reload.estimated_raw_cost
      assert_equal nil, @project.reload.estimated_cost
    end
    
    should "reflect contract invoiced" do
      @inv = Factory :contract_cost, :contract => @contract, :raw_cost => 1000
      
      assert_equal 1000, @project.reload.raw_contract_invoiced
      assert_equal 2000, @project.reload.contract_invoiced
      assert_equal 1000, @project.reload.raw_cost
      assert_equal 2000, @project.reload.cost
      
      @inv.destroy
      
      assert_equal nil, @project.reload.raw_contract_invoiced
      assert_equal nil, @project.reload.contract_invoiced
      assert_equal nil, @project.reload.raw_cost
      assert_equal nil, @project.reload.cost
    end
  end
end
