require File.dirname(__FILE__) + '/../test_helper'

class RelativeDeadlineTest < ActiveSupport::TestCase
  context "A Relative Deadline" do
    setup do
      @deadline = Factory :deadline, :date => '1/1/2000'
      @obj = Factory :relative_deadline, :parent_deadline => @deadline, :interval => 5
      
      @t1 = Factory :task, :deadline => @obj
      @t2 = Factory :task, :deadline => @obj
    end

    teardown do
      RelativeDeadline.delete_all
      Deadline.delete_all
      Task.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.interval
    end
    
    should "require a parent deadline" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :relative_deadline, :parent_deadline => nil
      end
    end
    
    should "allow multiple tasks" do
      assert_contains @obj.tasks, @t1
      assert_contains @obj.tasks, @t2
    end
    
    should "determine date" do
      assert_equal @obj.date, Date.parse('2000-1-6')
    end
  end
end
