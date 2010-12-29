require File.dirname(__FILE__) + '/../test_helper'

class MarkupTest < ActiveSupport::TestCase
  context "A Markup" do
    setup do
      @project = Factory :project
      @component = Factory :component, :name => 'component'
      @task = Factory :task
      @contract = Factory :contract
      @bid = Factory :bid, :contract => @contract, :raw_cost => 100
 
      @obj = Factory( :markup, :name => 'test markup', :percent => 50 )
      @obj.projects << @project
      @obj.components << @component
      @obj.tasks << @task

      @subcomponent = Factory :component, :parent => @component, :name => 'subcomponent'
      @inherited_component = Factory :component, :project => @project
      @inherited_task = Factory :task, :project => @project
      
      Factory :fixed_cost_estimate, :component => @component, :raw_cost => 100
      Factory :fixed_cost_estimate, :component => @subcomponent, :raw_cost => 100
      Factory :material_cost, :task => @task, :raw_cost => 100
      
      [@project, @component, @subcomponent, @task, @bid, @obj].each {|i| i.reload}
    end
=begin
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
    
    should "copy from project to task" do
      assert_contains @inherited_task.markups, @obj
    end
    
    should "cascade add / delete from project to task" do
      @new1 = Factory :markup
      @new2 = Factory :markup
      @new3 = Factory :markup, :markings_attributes => [{:markupable_type => 'Project', :markupable_id => @project.id}]
      @new1.projects << @project
      @project.markups << @new2
      
      assert_contains @inherited_task.markups.reload.all, @new1
      assert_contains @inherited_task.markups.reload.all, @new2
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

      assert_contains @inherited_component.markups.reload.all, @new1
      assert_contains @inherited_component.markups.reload.all, @new2
      
      @new1.projects.delete( @project )
      @project.markups.delete( @new2 )
      
      assert_does_not_contain @inherited_component.markups.reload.all, @new1
      assert_does_not_contain @inherited_component.markups.reload.all, @new2
    end
        
    should "copy from component to subcomponent" do
      assert_contains @subcomponent.markups, @obj
    end

    should "cascade add / delete from component to subcomponent" do
      @sub2 = Factory :component, :parent => @subcomponent, :name => 'sub2'
      @sub3 = Factory :component, :parent => @sub2, :name => 'sub3'
    
      @new1 = Factory :markup
      @new2 = Factory :markup
      @new1.components << @component
      @component.markups << @new2
      
      assert_contains @subcomponent.markups.reload.all, @new1
      assert_contains @subcomponent.markups.reload.all, @new2
      
      @sub2.markups.delete(@new2)
      @sub3.markups << @new2
      @new1.components.delete( @component )
      @component.markups.delete( @new2 )
      
      assert_does_not_contain @subcomponent.markups.reload.all, @new1
      assert_does_not_contain @subcomponent.markups.reload.all, @new2
      assert_does_not_contain @sub3.markups.reload.all, @new2
    end

    # -----------------------CALCULATIONS
=end
    should "apply to markupable" do
      assert_equal 50, @obj.apply_to(@subcomponent, :estimated_raw_component_cost)
      assert_equal 50, @obj.apply_to(@component, :estimated_raw_component_cost)
    end
    
    should "apply to markupable and children" do
      
      assert_equal 50, @subcomponent.subtree.joins(:markings).sum('markings.estimated_fixed_cost_markup_amount').to_f
      assert_equal 50, @subcomponent.subtree.joins(:markings).sum('markings.estimated_cost_markup_amount').to_f
      
      assert_equal 50, @obj.apply_recursively_to(@subcomponent, :estimated_cost_markup_amount)
      assert_equal 100, @obj.apply_recursively_to(@component, :estimated_cost_markup_amount)
      assert_equal 150, @obj.apply_recursively_to(@project, :estimated_cost_markup_amount)
    end
  end
end
