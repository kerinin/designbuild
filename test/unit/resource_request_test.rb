require File.dirname(__FILE__) + '/../test_helper'

class ResourceRequestTest < ActiveSupport::TestCase
  context "A Resource Request" do
    setup do
      @project = Factory.build :project
      @resource = Factory.build :resource
      @task = Factory.build :task
      
      @obj = Factory.build :resource_request, :project => @project, :resource => @resource, :task => @task, :duration => 5
      
      @a1 = @obj.resource_allocations.build :resource_request => @obj, :start_date => Date::today, :duration => 1
      @a2 = @obj.resource_allocations.build :resource_request => @obj, :start_date => Date::today, :duration => 1
    end
    
    should "be valid" do
      @obj.save!
      assert @obj.valid?
    end

    should "require duration" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :resource_request, :duration => nil
      end
    end
        
    should "require associated project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :resource_request, :project_id => nil
      end
      
      assert_equal @project, @obj.project
    end
    
    should "require associated resource" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :resource_request, :resource_id => nil
      end
      
      assert_equal @resource, @obj.resource
    end
    
    should "allow associated task" do
      assert_equal @task, @obj.task
    end
    
    should "allow associated allocations" do
      assert_contains @obj.resource_allocations, @a1
      assert_contains @obj.resource_allocations, @a2
    end
    
    should "determine allocated" do
      @a1.save!
      @a2.save!
      @obj.save!
      assert_equal 2, @obj.allocated
    end
    
    should "determine remaining" do
      @a1.save!
      @a2.save!
      @obj.save!
      assert_equal 3, @obj.remaining
    end
    
    should "zero remaining if negative" do
      @a1.save!
      @a2.save!
      @obj.resource_allocations.create :resource_request => @obj, :start_date => Date::today, :duration => 10
      @obj.save!
      assert_equal 0, @obj.remaining
    end
    
    should "update allocated on new allocation" do
      @a1.save!
      @a2.save!
      @obj.save!
      assert_equal 2, @obj.reload.allocated
      
      ResourceAllocation.create!( :resource_request => @obj, :duration => 1, :start_date => Date::today)
      assert_equal 3, @obj.reload.allocated
    end
    
    should "update allocation on destroyed allocation" do
      @a1.save!
      @a2.save!
      @obj.save!
      assert_equal 2, @obj.reload.allocated
      
      @a1.destroy
      assert_equal 1, @obj.reload.allocated
    end
  end
end
