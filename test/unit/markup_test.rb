require File.dirname(__FILE__) + '/../test_helper'

class MarkupTest < ActiveSupport::TestCase
  context "A Markup" do
    setup do
      @project = Factory :project
      @obj = Factory :markup, :parent => @project, :name => 'test markup', :percent => 50
      
      @component = Factory :component
      @subcomponent = Factory :component, :parent => @component
      @subcomponent.markups = []
      @task = Factory :task
      @contract = Factory :contract
      @bid = Factory :bid, :contract => @contract, :cost => 100
      @contract.active_bid = @bid
      @contract.save
      
      @component_m = Factory :markup, :parent => @component, :percent => 50
      @task_m = Factory :markup, :parent => @task, :percent => 50
      @contract_m = Factory :markup, :parent => @contract, :percent => 50
      
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
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.percent
    end
    
    should "require a parent" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :markup
      end
    end
    
    #------------------------ASSOCIATIONS
    
    should "allow associated projects" do
      assert_equal @obj.parent, @project
      assert_contains @project.markups, @obj
    end
    
    should "allow associatied components" do
      assert_equal @component_m.parent, @component
      assert_contains @component.markups, @component_m
    end
    
    should "allow associated tasks" do
      assert_equal @task_m.parent, @task
      assert_contains @task.markups, @task_m
    end
    
    should "allow associated contracts" do
      assert_equal @contract_m.parent, @contract
      assert_contains @contract.markups, @contract_m
    end
    
    should "copy from project to task" do
      assert_equal @inherited_task.markups.first.name, 'test markup'
      assert_equal @inherited_task.markups.first.percent, 50
    end
    
    should "copy from project to component" do
      assert_equal @inherited_component.markups.first.name, 'test markup'
      assert_equal @inherited_component.markups.first.percent, 50
    end
    
    should "copy from project to contract" do
      assert_equal @inherited_contract.markups.first.name, 'test markup'
      assert_equal @inherited_contract.markups.first.percent, 50
    end
    
    # -----------------------CALCULATIONS
    
    should "apply to parent" do
      assert_equal @component.estimated_component_cost, 150
      assert_equal @task.cost, 150
      assert_equal @contract.cost, 150
      assert_equal @contract.estimated_cost, 150
    end
    
    should "inherit from parent component's markup" do
      assert @subcomponent.markups.empty?
      assert_equal 150, @subcomponent.estimated_component_cost
    end
  end
end
