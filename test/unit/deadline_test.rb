require File.dirname(__FILE__) + '/../test_helper'

class DeadlineTest < ActiveSupport::TestCase
  context "A Deadline" do
    setup do
      @obj = Factory :deadline, :date => '1/1/2000'
      @r_deadline = Factory :deadline, :parent_deadline => @obj, :interval => 5
      
      @t1 = Factory :task, :deadline => @obj
      @t2 = Factory :task, :deadline => @obj
      @rd1 = Factory :deadline, :parent_deadline => @obj, :interval => 10
      @rd2 = Factory :deadline, :parent_deadline => @obj, :interval => 10
      @rr_deadline = Factory :deadline, :parent_deadline => @r_deadline, :interval => 5
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

    should "require an interval if parent set" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :deadline, :interval => nil, :parent_deadline => @obj
      end
    end
            
    should "scope absolute" do
      assert_contains Deadline.scoped.absolute.all, @obj
      assert_does_not_contain Deadline.scoped.absolute.all, @r_deadline
      assert_does_not_contain Deadline.scoped.absolute.all, @rd1
      assert_does_not_contain Deadline.scoped.absolute.all, @rd2
    end
    
    should "scope relative" do
      assert_does_not_contain Deadline.scoped.relative.all, @obj
      assert_contains Deadline.scoped.relative.all, @r_deadline
      assert_contains Deadline.scoped.relative.all, @rd1
      assert_contains Deadline.scoped.relative.all, @rd2
    end

    should "return is_absolute" do
      assert_equal true, @obj.is_absolute?
      assert_equal false, @r_deadline.is_absolute?
      assert_equal false, @rd1.is_absolute?
      assert_equal false, @rd2.is_absolute?
    end
    
    should "return is_relative" do
      assert_equal false, @obj.is_relative?
      assert_equal true, @r_deadline.is_relative?
      assert_equal true, @rd1.is_relative?
      assert_equal true, @rd2.is_relative?
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
      assert_equal @rr_deadline.date, Date.parse('2000-1-11')
    end
    
    should "update date when parent updates" do
      @obj.date = '1/1/2010'
      @obj.save!
      
      assert_equal Date.parse('2010-1-6'), Deadline.find(@r_deadline.id).date
      assert_equal Date.parse('2010-1-11'), Deadline.find(@rr_deadline.id).date
      
      @r_deadline.interval = 10
      @r_deadline.save!
      
      assert_equal Date.parse('2010-1-11'), Deadline.find(@r_deadline.id).date
      assert_equal Date.parse('2010-1-16'), Deadline.find(@rr_deadline.id).date
    end
  end
end
