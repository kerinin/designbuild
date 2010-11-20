require File.dirname(__FILE__) + '/../test_helper'

class MarkupTest < ActiveSupport::TestCase
  context "A Markup" do
    setup do
      @project = Factory :project
      @component = Factory :component
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

      @subcomponent = Factory :component, :parent => @component
      @inherited_component = Factory :component, :project => @project
      @inherited_task = Factory :task, :project => @project
      @inherited_contract = Factory :contract, :project => @project
      
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
    
    should "copy from project to task" do
      assert_contains @inherited_task.markups, @obj
    end
    
    should "cascade add / delete from project to task" do
      @new1 = Factory :markup
      @new2 = Factory :markup
      @new3 = Factory :markup, :markings_attributes => [{:markupable_type => 'Project', :markupable_id => @project.id}]
      @new1.projects << @project
      @project.markups << @new2
      
      assert_contains @inherited_task.markups, @new1
      assert_contains @inherited_task.markups, @new2
      assert_contains @new3.projects, @project
      assert_contains @new3.components, @inherited_component
      
      @new1.projects.delete( @project )
      @project.markups.delete( @new2 )
      
      # AR not keeping up...
      assert_does_not_contain Task.find(@inherited_task.id).markups, @new1
      assert_does_not_contain Task.find(@inherited_task.id).markups, @new2
    end
    
    should "copy from project to component" do
      assert_contains @inherited_component.markups, @obj
    end
    
    should "cascade add / delete from project to component" do
      @new1 = Factory :markup
      @new2 = Factory :markup
      @new1.projects << @project
      @project.markups << @new2

      assert_contains @inherited_component.markups, @new1
      assert_contains @inherited_component.markups, @new2
      
      @new1.projects.delete( @project )
      @project.markups.delete( @new2 )
      
      assert_does_not_contain Component.find(@inherited_component.id).markups, @new1
      assert_does_not_contain Component.find(@inherited_component.id).markups, @new2
    end
        
    should "copy from component to subcomponent" do
      assert_contains @subcomponent.markups, @obj
    end

    should "cascade add / delete from component to subcomponent" do
      @sub2 = Factory :component, :parent => @subcomponent
      @sub3 = Factory :component, :parent => @sub2
    
      @new1 = Factory :markup
      @new2 = Factory :markup
      @new1.components << @component
      @component.markups << @new2
      
      assert_contains @subcomponent.markups, @new1
      assert_contains @subcomponent.markups, @new2
      
      @sub2.markups.delete(@new2)
      @sub3.markups << @new2
      @new1.components.delete( @component )
      @component.markups.delete( @new2 )
      
      assert_does_not_contain Component.find(@subcomponent.id).markups, @new1
      assert_does_not_contain Component.find(@subcomponent.id).markups, @new2
      assert_does_not_contain Component.find(@sub3.id).markups, @new2
    end
        
    should "copy from project to contract" do
      assert_contains @inherited_contract.markups, @obj
    end
    
    should "cascade add / delete from project to contract" do
      @new1 = Factory :markup
      @new2 = Factory :markup
      @new1.projects << @project
      @project.markups << @new2
      
      assert_contains @inherited_contract.markups, @new1
      assert_contains @inherited_contract.markups, @new2
      
      @new1.projects.delete( @project )
      @project.markups.delete( @new2 )
      
      assert_does_not_contain Contract.find(@inherited_contract.id).markups, @new1
      assert_does_not_contain Contract.find(@inherited_contract.id).markups, @new2
    end

    # -----------------------CALCULATIONS
    
    should "apply to markupable" do
      assert_equal @component.estimated_component_cost, 150
      assert_equal @task.cost, 150
      assert_equal @contract.cost, 150
      assert_equal @contract.estimated_cost, 150
    end
  end
end
