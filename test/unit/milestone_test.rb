require File.dirname(__FILE__) + '/../test_helper'

class MilestoneTest < ActiveSupport::TestCase
  context "A Milestone" do
    setup do
      @project = Factory :project
      @t1 = Factory :task, :project => @project
      @t2 = Factory :task, :project => @project
      
      @obj = Factory :milestone, :date => '1/1/2000', :task => @t1
      @r_milestone = Factory :milestone, :parent_date => @obj, :interval => 5, :task => @t2
      
      @rd1 = Factory :milestone, :parent_date => @obj, :interval => 10
      @rd2 = Factory :milestone, :parent_date => @obj, :interval => 10
      @rr_milestone = Factory :milestone, :parent_date => @r_milestone, :interval => 5
    end

    teardown do
      Milestone.delete_all
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
        Factory :milestone, :project => nil
      end
    end

    should "require a task" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :milestone, :task => nil
      end
    end
        
    should "require an interval and parent if no date set" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :milestone, :parent_date => nil, :date => nil
      end
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :milestone, :interval => nil, :date => nil
      end
    end

    should "require an interval if parent set" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :milestone, :interval => nil, :parent_date => @obj
      end
    end
    
    should "allow a finish date" do
      @obj.date_completed = Date::today
      assert @obj.valid?
    end
    
    should_eventually "set finished if all tasks 100%" do
      @t1.percent_complete = 100
      @t1.save
      
      assert_equal @obj.date_completed, Date::today
    end
    
    should_eventually "set tasks 100% if finished" do
      @obj.date_completed = Date::today
      @obj.save
      
      assert_equal @t1.percent_complete, 100
    end
    
    should "revise relative milestones when finished" do
      @obj.date_completed = Date::today + 10
      @obj.save
      
      assert_equal @rd1.reload.date, Date::today + 20
      assert_equal @rd2.reload.date, Date::today + 20
      assert_equal @rr_milestone.reload.date, Date::today + 20
    end
            
    should "scope absolute" do
      assert_contains Milestone.scoped.absolute.all, @obj
      assert_does_not_contain Milestone.scoped.absolute.all, @r_milestone
      assert_does_not_contain Milestone.scoped.absolute.all, @rd1
      assert_does_not_contain Milestone.scoped.absolute.all, @rd2
    end
    
    should "scope relative" do
      assert_does_not_contain Milestone.scoped.relative.all, @obj
      assert_contains Milestone.scoped.relative.all, @r_milestone
      assert_contains Milestone.scoped.relative.all, @rd1
      assert_contains Milestone.scoped.relative.all, @rd2
    end

    should "return is_absolute" do
      assert_equal true, @obj.is_absolute?
      assert_equal false, @r_milestone.is_absolute?
      assert_equal false, @rd1.is_absolute?
      assert_equal false, @rd2.is_absolute?
    end
    
    should "return is_relative" do
      assert_equal false, @obj.is_relative?
      assert_equal true, @r_milestone.is_relative?
      assert_equal true, @rd1.is_relative?
      assert_equal true, @rd2.is_relative?
    end
    
    should "allow multiple relative milestones" do
      assert_contains @obj.relative_milestones, @rd1
      assert_contains @obj.relative_milestones, @rd2
    end
    
    should "allow a parent milestone" do
      assert_equal @r_milestone.parent_date, @obj
    end
    
    should "determine date" do
      assert_equal @r_milestone.date, Date.parse('2000-1-6')
      assert_equal @rr_milestone.date, Date.parse('2000-1-11')
    end
    
    should "update date when parent updates" do
      @obj.date = '1/1/2010'
      @obj.save!
      
      assert_equal Date.parse('2010-1-6'), @r_milestone.reload.date
      assert_equal Date.parse('2010-1-11'), @rr_milestone.reload.date
      
      @r_milestone.interval = 10
      @r_milestone.save!
      
      assert_equal Date.parse('2010-1-11'), @r_milestone.reload.date
      assert_equal Date.parse('2010-1-16'), @rr_milestone.reload.date
    end
  end
  
  context "A Milestone" do
    setup do
      @project = Factory :project
      @task1 = Factory :task, :project => @project
      @task2 = Factory :task, :project => @project
      @task3 = Factory :task, :project => @project
      
      @deadline = Factory :deadline, :project => @project, :tasks => [@task1, @task2], :date => (Date::today + 5)
      
      @m1_1 = Factory :milestone, :project => @project, :task => @task1, :date => (Date::today)
      @m1_2 = Factory :milestone, :project => @project, :task => @task1, :parent_date => @m1_1, :interval => 2

      @m2_1 = Factory :milestone, :project => @project, :task => @task2, :date => (Date::today)
      @m2_2 = Factory :milestone, :project => @project, :task => @task2, :parent_date => @m2_1, :interval => 10
      
      @m3_1 = Factory :milestone, :project => @project, :task => @task3, :parent_date => @deadline, :interval => -10
      @m3_2 = Factory :milestone, :project => @project, :task => @task3, :date => (Date::today + 5)
    end

    teardown do
      Milestone.delete_all
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
      assert_equal @m3_1.task, @task3
      assert_equal @m3_2.task, @task3
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
      @m1_1.date_completed = Date::today
      @m1_2.date_completed = Date::today
      @m2_1.date_completed = Date::today
      @m2_2.date_completed = Date::today
      @m3_1.date_completed = Date::today
      @m3_2.date_completed = Date::today

      assert @m1_1.valid?
      assert @m1_2.valid?
      assert @m2_1.valid?
      assert @m2_2.valid?
      assert @m3_1.valid?
      assert @m3_2.valid?      
    end
    
    should "update relative milestones based on finish date" do
      @m1_1.date_completed = Date::today - 10
      @m2_1.date_completed = Date::today - 10
      @deadline.date_completed = Date::today - 10
      @m1_1.save
      @m2_1.save
      @deadline.save
      
      assert_equal @m1_2.reload.date, Date::today - 8
      assert_equal @m2_2.reload.date, Date::today
      assert_equal @m3_1.reload.date, Date::today - 20
    end
    
    should "not modify task when finished" do
      @m1_1.date_completed = Date::today
      @m1_2.date_completed = Date::today
      @m2_1.date_completed = Date::today
      @m2_2.date_completed = Date::today
      @m3_1.date_completed = Date::today
      @m3_2.date_completed = Date::today
      
      assert_equal 0, @task1.percent_complete
      assert_equal 0, @task2.percent_complete
      assert_equal 0, @task3.percent_complete
    end
    
    should_eventually "set finish date when task 100%" do
      @task1.percent_complete = 100
      @task2.percent_complete = 100
      @task3.percent_complete = 100
      
      assert_equal @m1_1.date_completed, Date::today
      assert_equal @m1_2.date_completed, Date::today
      assert_equal @m2_1.date_completed, Date::today
      assert_equal @m2_2.date_completed, Date::today
      assert_equal @m3_1.date_completed, Date::today
      assert_equal @m3_2.date_completed, Date::today
    end
  end
end
