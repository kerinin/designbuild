require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  context "A Project" do
    setup do
      @obj = Factory :project
      
      @u1 = Factory :user, :projects => [@obj]
      #@u2 = Factory :user, :projects => [@obj]
      @c1 = Factory :component, :project => @obj
      @c2 = Factory :component, :project => @obj
      @t1 = Factory :task, :project => @obj
      @t2 = Factory :task, :project => @obj
      @cont1 = Factory :contract, :project => @obj
      @cont2 = Factory :contract, :project => @obj
      @dl1 = Factory :deadline, :project => @obj
      @dl2 = Factory :deadline, :project => @obj
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
    
    should "allow multiple deadlines" do
      assert_contains @obj.deadlines, @dl1
      assert_contains @obj.deadlines, @dl2
    end
  end
end
