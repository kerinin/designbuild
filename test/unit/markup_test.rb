require File.dirname(__FILE__) + '/../test_helper'

class MarkupTest < ActiveSupport::TestCase
  context "A Markup" do
    setup do
      @project = Factory :project
      @obj = Factory :markup, :parent => @project
      
      @component = Factory :component
      @task = Factory :task
      @contract = Factory :task
      
      @project_m = Factory :markup, :parent => @project
      @component_m = Factory :markup, :parent => @component
      @task_m = Factory :markup, :parent => @task
      @contract_m = Factory :markup, :parent => @contract
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
    
    should "allow associated projects" do
      assert_equal @project_m.parent, @project
      assert_contains @project.default_markups, @project_m
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
  end
end
