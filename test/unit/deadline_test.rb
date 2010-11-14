require File.dirname(__FILE__) + '/../test_helper'

class DeadlineTest < ActiveSupport::TestCase
  context "A Deadline" do
    setup do
      @obj = Factory :deadline
      
      @t1 = Factory :task, :deadline => @obj
      @t2 = Factory :task, :deadline => @obj
      @rd1 = Factory :relative_deadline, :parent_deadline => @obj
      @rd2 = Factory :relative_deadline, :parent_deadline => @obj
    end

    teardown do
      Deadline.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.date
    end
    
    should "require a project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :deadline, :project => nil
      end
    end
    
    should "allow multiple tasks" do
      assert_contains @obj.tasks, @t1
      assert_contains @obj.tasks, @t2
    end
    
    should "allow multiple relative deadlines" do
      assert_contains @obj.relative_deadlines, @rd1
      assert_contains @obj.relative_deadlines, @rd2
    end
  end
end
