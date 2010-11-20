require File.dirname(__FILE__) + '/../test_helper'

class MarkupTest < ActiveSupport::TestCase
  context "A Markup" do
    setup do
      @project = Factory :project
      @component = Factory :component
      @subcomponent = Factory :component, :parent => @component
      @task = Factory :task
      @contract = Factory :contract
      @bid = Factory :bid, :contract => @contract, :cost => 100
      @contract.active_bid = @bid
      @contract.save
 
       @obj = Factory( :markup, :name => 'test markup', :percent => 50 )
       @obj.projects << @project
       @obj.components << @component
       @obj.tasks << @task
       @obj.contracts << @contract 

      
      @inherited_component = Factory :component, :project => @project
      @inherited_task = Factory :task, :project => @project
      @inherited_contract = Factory :task, :project => @project
      
      Factory :fixed_cost_estimate, :component => @component, :cost => 100
      Factory :fixed_cost_estimate, :component => @subcomponent, :cost => 100
      Factory :material_cost, :task => @task, :cost => 100
      Factory :contract_cost, :contract => @contract, :cost => 100
    end

    teardown do
      Markup.delete_all
      Project.delete_all
      Component.delete_all
      Task.delete_all
      Contract.delete_all
      Marking.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.percent
    end
    
    #------------------------ASSOCIATIONS
    
    should "allow associated projects" do
      assert_contains @obj.projects, @project
      assert_contains @project.markups, @obj
    end
    
    should "allow associatied components" do
      assert_contains @obj.components, @component
      assert @component.markings.count != 0
      assert_contains @component.markups, @obj
    end
    
    should "allow associated tasks" do
      assert_contains @obj.tasks, @task
      assert_contains @task.markups, @obj
    end
    
    should "allow associated contracts" do
      assert_contains @obj.contracts, @contract
      assert_contains @contract.markups, @obj
    end
    
    should_eventually "copy from project to task" do
      assert_equal @inherited_task.markups.first.name, 'test markup'
      assert_equal @inherited_task.markups.first.percent, 50
    end
    
    should_eventually "cascade delete from project to task" do
    end
    
    should_eventually "copy from project to component" do
      assert_equal @inherited_component.markups.first.name, 'test markup'
      assert_equal @inherited_component.markups.first.percent, 50
    end

    should_eventually "cascade delete from project to component" do
    end
        
    should_eventually "copy from component to subcomponent" do
    end

    should_eventually "cascade delete from component to subcomponent" do
    end
        
    should_eventually "copy from project to contract" do
      assert_equal @inherited_contract.markups.first.name, 'test markup'
      assert_equal @inherited_contract.markups.first.percent, 50
    end
    
    should_eventually "cascade delete from project to contract" do
    end
    # -----------------------CALCULATIONS
    
    should_eventually "apply to parent" do
      assert_equal @component.estimated_component_cost, 150
      assert_equal @task.cost, 150
      assert_equal @contract.cost, 150
      assert_equal @contract.estimated_cost, 150
    end
  end
end
