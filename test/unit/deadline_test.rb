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
    
    should "allow a finish date" do
      @obj.finish_date = Date::today
      assert @obj.valid?
    end
    
    should "set finished if all tasks 100%" do
      @t1.percent_complete = 100
      @t2.percent_complete = 100
      @t1.save
      @t2.save
      
      assert_equal @obj.finish_date, Date::today
    end
    
    should_eventually "set tasks 100% if finished" do
      @obj.finish_date = Date::today
      @obj.save
      
      assert_equal @t1.percent_complete, 100
      assert_equal @t2.percent_complete, 100
    end
    
    should "revise relative deadlines when finished" do
      @obj.finish_date = Date::today + 10
      @obj.save
      
      assert_equal @rd1.date, Date::today + 20
      assert_equal @rd2.date, Date::today + 20
      assert_equal @rr_deadline.date, Date::today + 25
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
      assert_equal @t1.deadline, @obj
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
  
  context "A Milestone" do
    setup do
      @project = Factory :project
      @task1 = Factory :task, :project => @project
      @task2 = Factory :task, :project => @project
      @task3 = Factory :task, :project => @project
      
      @deadline = Factory :deadline, :project => @project, :tasks => [@task1, @task2], :date => (Date::today + 5)
      
      @m1_1 = Factory :deadline, :project => @project, :task => @task1, :date => (Date::today)
      @m1_2 = Factory :deadline, :project => @project, :task => @task1, :parent_deadline => @m1_1, :interval => 2

      @m2_1 = Factory :deadline, :project => @project, :task => @task2, :date => (Date::today)
      @m2_2 = Factory :deadline, :project => @project, :task => @task2, :parent_deadline => @m2_1, :interval => 10
      
      @m3_1 = Factory :deadline, :project => @project, :task => @task3, :parent_deadline => @deadline, :interval => -10
      @m3_2 = Factory :deadline, :project => @project, :task => @task3, :date => (Date::today + 5)
    end

    teardown do
      Deadline.delete_all
    end
    
    should "be valid" do
      assert @m1_1.valid?
      assert @m1_2.valid?
      assert @m2_1.valid?
      assert @m2_2.valid?
      assert @m3_1.valid?
      assert @m3_2.valid?
    end
    
    should "have a task" do
      assert_equal @m1_1.task, @task1
      assert_equal @m1_2.task, @task1
      assert_equal @m2_1.task, @task2
      assert_equal @m2_2.task, @task2
      assert_equal @m3_3.task, @task3
      assert_equal @m3_3.task, @task3
    end
    
    should "show up in tasks" do
      assert_contains @task1.milestones.all, @m1_1
      assert_contains @task1.milestones.all, @m1_2
      assert_contains @task2.milestones.all, @m2_1
      assert_contains @task2.milestones.all, @m2_2
      assert_contains @task3.milestones.all, @m3_1
      assert_contains @task3.milestones.all, @m3_2
    end
    
    should "allow finish date" do
      @m1_1.finish_date = Date::today
      @m1_2.finish_date = Date::today
      @m2_1.finish_date = Date::today
      @m2_2.finish_date = Date::today
      @m3_1.finish_date = Date::today
      @m3_2.finish_date = Date::today

      assert @m1_1.valid?
      assert @m1_2.valid?
      assert @m2_1.valid?
      assert @m2_2.valid?
      assert @m3_1.valid?
      assert @m3_2.valid?      
    end
    
    should "update relative milestones based on finish date" do
      @m1_1.finish_date = Date::today - 10
      @m2_1.finish_date = Date::today - 10
      @deadline.finish_date = Date::today - 10
      
      assert_equal @m1_2.date, Date::today - 8
      assert_equal @m2_2.date, Date::today
      assert_equal @m3_1.date, Date::today - 20
    end
    
    should "not modify task when finished" do
      @m1_1.finish_date = Date::today
      @m1_2.finish_date = Date::today
      @m2_1.finish_date = Date::today
      @m2_2.finish_date = Date::today
      @m3_1.finish_date = Date::today
      @m3_2.finish_date = Date::today
      
      assert_equal nil, @task1.percent_complete
      assert_equal nil, @task2.percent_complete
      assert_equal nil, @task3.percent_complete
    end
    
    should "set finish date when task 100%" do
      @task1.percent_complete = 100
      @task2.percent_complete = 100
      @task3.percent_complete = 100
      
      assert_equal @m1_1.finish_date, Date::today
      assert_equal @m1_2.finish_date, Date::today
      assert_equal @m2_1.finish_date, Date::today
      assert_equal @m2_2.finish_date, Date::today
      assert_equal @m3_1.finish_date, Date::today
      assert_equal @m3_2.finish_date, Date::today
    end
  end
end
