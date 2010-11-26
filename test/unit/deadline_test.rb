require File.dirname(__FILE__) + '/../test_helper'

class DeadlineTest < ActiveSupport::TestCase
  context "A Deadline" do
    setup do
      @obj = Factory :deadline, :date => '1/1/2000'
      @r_deadline = Factory :deadline, :parent_deadline => @obj, :interval => 5
      
      @t1 = Factory :task, :deadline => @obj
      @t2 = Factory :task, :deadline => @obj
      @rd1 = Factory :deadline, :parent_deadline => @obj
      @rd2 = Factory :deadline, :parent_deadline => @obj
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
    
    should "require an interval and parent if no date set" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :deadline, :parent_deadline => nil, :date => nil
      end
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :deadline, :interval => nil, :date => nil
      end
    end

    should "be invalid if parent and date are both set" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :deadline, :parent_deadline => @obj, :date => '1/1/2000'
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
    
    should "allow a parent deadline" do
      assert_equal @r_deadline.parent_deadline, @obj
    end
    
    should "determine date" do
      assert_equal @r_deadline.date, Date.parse('2000-1-6')
    end
  end
end
