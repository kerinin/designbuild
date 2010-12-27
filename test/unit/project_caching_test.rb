require File.dirname(__FILE__) + '/../test_helper'

class ProjectCachingTest < ActiveSupport::TestCase
  context "A project w/ caching" do
    setup do
      @project = Factory :project, :markups => [ Factory :markup, :percent => 100 ], :name => 'project'
      #@component = Factory :component, :project => @project, :name => 'component'
      @component = @project.components.create! :name => 'component'
      #@subcomponent = Factory :component, :parent => @component, :name => 'subcomponent'
      @subcomponent = @project.components.create! :name => 'subcomponent'
      @component.children << @subcomponent
      #@task = Factory :task, :project => @project
      @task = @project.tasks.create! :name => 'task'
      #@contract = Factory :contract, :project => @project
      @contract = @project.contracts.create! :name => 'contract'
      #@contract1 = Factory :contract, :component => @component, :project => @project
      @contract1 = @project.contracts.create! :name => 'contract1'
      @component.contracts << @contract1
      #@contract2 = Factory :contract, :component => @subcomponent, :project => @project
      @contract2 = @project.contracts.create! :name => 'contract2'
      @subcomponent.contracts << @contract2
      @laborer = Factory :laborer, :bill_rate => 1
      @random_component = Factory :component
      @random_task = Factory :task
      
      [@project, @component, @subcomponent].each {|i| i.reload}
    end

    should "reflect root unit costs" do
      @q = Factory :quantity, :component => @component, :value => 1
      @uc = Factory :unit_cost_estimate, :component => @component, :quantity => @q, :unit_cost => 100, :drop => 0
      
      assert_equal 100, @project.reload.estimated_raw_unit_cost
      assert_equal 200, @project.reload.estimated_unit_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost

      @uc.component = @random_component
      @uc.save

      assert_equal 0, @project.reload.estimated_raw_unit_cost
      assert_equal 0, @project.reload.estimated_unit_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost

      @uc.component = @component
      @uc.save

      assert_equal 100, @project.reload.estimated_raw_unit_cost
      assert_equal 200, @project.reload.estimated_unit_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
                        
      @uc.destroy
      
      assert_equal 0, @project.reload.estimated_raw_unit_cost
      assert_equal 0, @project.reload.estimated_unit_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost
    end
   
    should "reflect subcomponent unit costs" do
      @q = Factory :quantity, :component => @subcomponent, :value => 1
      @uc = Factory :unit_cost_estimate, :component => @subcomponent, :quantity => @q, :unit_cost => 100, :drop => 0, :name => 'unit cost'
      
      assert_equal 100, @project.reload.estimated_raw_unit_cost
      assert_equal 200, @project.reload.estimated_unit_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost

      @uc.component = @random_component
      @uc.save
      
      assert_equal 0, @project.reload.estimated_raw_unit_cost
      assert_equal 0, @project.reload.estimated_unit_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost

      @uc.component = @subcomponent
      @uc.save

      assert_equal 100, @project.reload.estimated_raw_unit_cost
      assert_equal 200, @project.reload.estimated_unit_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
            
      @uc.destroy
      
      assert_equal 0, @project.reload.estimated_raw_unit_cost
      assert_equal 0, @project.reload.estimated_unit_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost
    end
    
    should "reflect root fixed costs" do
      @fc = Factory :fixed_cost_estimate, :component => @component, :raw_cost => 100
      
      assert_equal 100, @project.reload.estimated_raw_fixed_cost
      assert_equal 200, @project.reload.estimated_fixed_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @fc.component = @random_component
      @fc.save
      
      assert_equal 0, @project.reload.estimated_raw_fixed_cost
      assert_equal 0, @project.reload.estimated_fixed_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost

      @fc.component = @component
      @fc.save

      assert_equal 100, @project.reload.estimated_raw_fixed_cost
      assert_equal 200, @project.reload.estimated_fixed_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @fc.destroy
      
      assert_equal 0, @project.reload.estimated_raw_fixed_cost
      assert_equal 0, @project.reload.estimated_fixed_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost
    end
  
    should "reflect subcomponent fixed costs" do
      @fc = Factory :fixed_cost_estimate, :component => @subcomponent, :raw_cost => 100
      
      assert_equal 100, @project.reload.estimated_raw_fixed_cost
      assert_equal 200, @project.reload.estimated_fixed_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @fc.component = @random_component
      @fc.save
      
      assert_equal 0, @project.reload.estimated_raw_fixed_cost
      assert_equal 0, @project.reload.estimated_fixed_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost

      @fc.component = @subcomponent
      @fc.save

      assert_equal 100, @project.reload.estimated_raw_fixed_cost
      assert_equal 200, @project.reload.estimated_fixed_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @fc.destroy
      
      assert_equal 0, @project.reload.estimated_raw_fixed_cost
      assert_equal 0, @project.reload.estimated_fixed_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost
    end

    should "reflect root contract costs" do
      #@bid = Factory :bid, :contract => @contract1, :raw_cost => 100
      @bid = @contract1.bids.create! :contractor => 'foo', :raw_cost => 100, :date => Date::today
      @contract1.active_bid = @bid
      @contract1.save
      
      #assert_equal @contract1.component, @component
      #assert_equal @contract1.project, @project
      
      # Caching forces the reload
      @project.reload
      
      assert_equal 100, @project.estimated_raw_contract_cost
      assert_equal 200, @project.estimated_contract_cost
      assert_equal 100, @project.estimated_raw_cost
      assert_equal 200, @project.estimated_cost

      @bid.raw_cost = 200
      @bid.save
      @project.reload
      
      assert_equal 200, @project.estimated_raw_contract_cost
      assert_equal 400, @project.estimated_contract_cost
      assert_equal 200, @project.estimated_raw_cost
      assert_equal 400, @project.estimated_cost
      
      @contract1.component = @random_component
      @contract1.project = @random_component.project
      @contract1.save
      @project.reload
      
      assert_equal 0, @project.estimated_raw_contract_cost
      assert_equal 0, @project.estimated_contract_cost
      assert_equal 0, @project.estimated_raw_cost
      assert_equal 0, @project.estimated_cost

      @contract1.component = @component
      @contract1.project = @project
      
      #puts 'begin'
      @contract1.save!
      #puts 'end'
      @project.reload

      #assert_equal 0, @project.contracts.without_component.sum(:estimated_raw_cost)
      #assert_equal 200, @component.estimated_raw_contract_cost
      #assert_contains @project.components.roots, @component
      #assert_equal 200, @project.components.roots.sum(:estimated_raw_contract_cost)
      #assert_equal 200, @project.components.roots.sum(:estimated_raw_cost)

      assert_equal 200, @project.estimated_raw_contract_cost
      assert_equal 400, @project.estimated_contract_cost
      assert_equal 200, @project.estimated_raw_cost
      assert_equal 400, @project.estimated_cost
      
      @bid.destroy
      @project.reload
      
      assert_equal 0, @project.estimated_raw_contract_cost
      assert_equal 0, @project.estimated_contract_cost
      assert_equal 0, @project.estimated_raw_cost
      assert_equal 0, @project.estimated_cost
    end
   
    should "reflect subcomponent contract costs" do
      @bid = Factory :bid, :contract => @contract2, :raw_cost => 100
      @contract2.active_bid = @bid
      @contract2.save
      
      assert_equal 100, @project.reload.estimated_raw_contract_cost
      assert_equal 200, @project.reload.estimated_contract_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost

      @bid.raw_cost = 200
      @bid.save
      
      assert_equal 200, @project.reload.estimated_raw_contract_cost
      assert_equal 400, @project.reload.estimated_contract_cost
      assert_equal 200, @project.reload.estimated_raw_cost
      assert_equal 400, @project.reload.estimated_cost
      
      
      @contract2.component = @random_component
      @contract2.project = @random_component.project
      @contract2.save
      
      assert_equal 0, @project.reload.estimated_raw_contract_cost
      assert_equal 0, @project.reload.estimated_contract_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost

      @contract2.component = @component
      @contract2.project = @project
      @contract2.save

      assert_equal 200, @project.reload.estimated_raw_contract_cost
      assert_equal 400, @project.reload.estimated_contract_cost
      assert_equal 200, @project.reload.estimated_raw_cost
      assert_equal 400, @project.reload.estimated_cost
          
      @bid.destroy
      
      assert_equal 0, @project.reload.estimated_raw_contract_cost
      assert_equal 0, @project.reload.estimated_contract_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost
    end
       
    should "reflect task labor costs" do
      @lc = Factory :labor_cost, :task => @task
      @ll = Factory :labor_cost_line, :labor_set => @lc, :laborer => @laborer, :hours => 100
      
      assert_equal 100, @project.reload.raw_labor_cost
      assert_equal 200, @project.reload.labor_cost
      assert_equal 100, @project.reload.raw_cost
      assert_equal 200, @project.reload.cost
      
      @lc.task = @random_task
      @lc.save
      
      assert_equal 0, @project.reload.raw_labor_cost
      assert_equal 0, @project.reload.labor_cost
      assert_equal 0, @project.reload.raw_cost
      assert_equal 0, @project.reload.cost

      @lc.task = @task
      @lc.save

      assert_equal 100, @project.reload.raw_labor_cost
      assert_equal 200, @project.reload.labor_cost
      assert_equal 100, @project.reload.raw_cost
      assert_equal 200, @project.reload.cost
      
      @lc.destroy
      
      assert_equal 0, @project.reload.raw_labor_cost
      assert_equal 0, @project.reload.labor_cost
      assert_equal 0, @project.reload.raw_cost
      assert_equal 0, @project.reload.cost
    end
    
    should "reflect task material costs" do
      #@mc = Factory :material_cost, :task => @task, :raw_cost => 100
      @mc = @task.material_costs.create! :raw_cost => 100, :date => Date::today, :supplier => Factory(:supplier)
      @project.reload
      
      assert_equal 100, @project.raw_material_cost
      assert_equal 200, @project.material_cost
      assert_equal 100, @project.raw_cost
      assert_equal 200, @project.cost
      
      @mc.task = @random_task
      @mc.save
      @project.reload
      
      assert_equal 0, @project.raw_material_cost
      assert_equal 0, @project.material_cost
      assert_equal 0, @project.raw_cost
      assert_equal 0, @project.cost

      @mc.task = @task
      @mc.save
      @project.reload

      assert_equal 100, @project.raw_material_cost
      assert_equal 200, @project.material_cost
      assert_equal 100, @project.raw_cost
      assert_equal 200, @project.cost
      
      @mc.destroy
      @project.reload
      
      assert_equal 0, @project.raw_material_cost
      assert_equal 0, @project.material_cost
      assert_equal 0, @project.raw_cost
      assert_equal 0, @project.cost
    end

    should "reflect contract estimated cost" do
      @bid = Factory :bid, :raw_cost => 100, :contract => @contract
      @contract.active_bid = @bid
      @contract.save
      
      assert_equal 100, @project.reload.estimated_raw_contract_cost
      assert_equal 200, @project.reload.estimated_contract_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @contract.project = @random_component.project
      @contract.save
      
      assert_equal 0, @project.reload.estimated_raw_contract_cost
      assert_equal 0, @project.reload.estimated_contract_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost

      @contract.project = @project
      @contract.save

      assert_equal 100, @project.reload.estimated_raw_contract_cost
      assert_equal 200, @project.reload.estimated_contract_cost
      assert_equal 100, @project.reload.estimated_raw_cost
      assert_equal 200, @project.reload.estimated_cost
      
      @bid.destroy
      
      assert_equal 0, @project.reload.estimated_raw_contract_cost
      assert_equal 0, @project.reload.estimated_contract_cost
      assert_equal 0, @project.reload.estimated_raw_cost
      assert_equal 0, @project.reload.estimated_cost
    end
    
    should "reflect contract cost" do
      @inv = Factory :contract_cost, :contract => @contract, :raw_cost => 1000
      
      assert_equal 1000, @project.reload.raw_contract_cost
      assert_equal 2000, @project.reload.contract_cost
      assert_equal 1000, @project.reload.raw_cost
      assert_equal 2000, @project.reload.cost
      
      @contract.project = @random_component.project
      @contract.save
      
      assert_equal 0, @project.reload.raw_contract_cost
      assert_equal 0, @project.reload.contract_cost
      assert_equal 0, @project.reload.raw_cost
      assert_equal 0, @project.reload.cost

      @contract.project = @project
      @contract.save

      assert_equal 1000, @project.reload.raw_contract_cost
      assert_equal 2000, @project.reload.contract_cost
      assert_equal 1000, @project.reload.raw_cost
      assert_equal 2000, @project.reload.cost
      
      @inv.destroy
      
      assert_equal 0, @project.reload.raw_contract_cost
      assert_equal 0, @project.reload.contract_cost
      assert_equal 0, @project.reload.raw_cost
      assert_equal 0, @project.reload.cost
    end
    
    should "update total markup after add" do
      @markup = Factory :markup, :percent => 10
      @project.markups << @markup
      assert_contains @component.reload.markups.all, @markup
      assert_equal 110, @component.reload.total_markup
      assert_equal 110, @subcomponent.reload.total_markup
      assert_equal 110, @task.reload.total_markup
      assert_equal 110, @contract.reload.total_markup
    end
    
    should "update component's task after cost change" do
      @fixed_cost = Factory :fixed_cost_estimate, :component => @component, :task => @task, :raw_cost => 100
      @quantity = Factory :quantity, :component => @component, :value => 1
      @unit_cost = Factory :unit_cost_estimate, :component => @component, :task => @task, :unit_cost => 100, :drop => 0, :quantity => @quantity
      @task.reload
      
      assert_contains @task.fixed_cost_estimates.all, @fixed_cost
      assert_contains @task.unit_cost_estimates.all, @unit_cost
      assert_equal 100, @fixed_cost.raw_cost
      assert_equal 100, @unit_cost.raw_cost
      assert_equal 200, @task.reload.estimated_raw_cost
      
      @fixed_cost.raw_cost = 200
      @fixed_cost.save
      
      assert_equal 300, @task.reload.estimated_raw_cost
      
      @unit_cost.unit_cost = 200
      @unit_cost.save
      
      assert_equal 400, @task.reload.estimated_raw_cost
      
      @quantity.value = 2
      @quantity.save
      
      assert_equal 600, @task.reload.estimated_raw_cost
    end

  end
end
