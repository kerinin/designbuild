require File.dirname(__FILE__) + '/../test_helper'

class ResourceRequestTest < ActiveSupport::TestCase
  context "A Resource Request" do
    setup do
      @project = Factory.build :project
      @resource = Factory.build :resource
      @task = Factory.build :task
      
      @obj = Factory.build :resource_request, :project => @project, :resources => [@resource], :task => @task
      
      @a1 = @obj.resource_allocations.build :resource_request => @obj, :start_date => Date::today, :duration => 1
      @a2 = @obj.resource_allocations.build :resource_request => @obj, :start_date => Date::today, :duration => 1
    end
    
    should "be valid" do
      @obj.save!
      assert @obj.valid?
    end
    
    should "require associated project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :resource_request, :project_id => nil
      end
      
      assert_equal @project, @obj.project
    end
    
    should_eventually "require associated resource" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :resource_request, :resource_id => nil
      end
      
      assert_contains @obj.resources, @resource
    end
    
    should "allow associated task" do
      assert_equal @task, @obj.task
    end
    
    should "allow associated allocations" do
      assert_contains @obj.resource_allocations, @a1
      assert_contains @obj.resource_allocations, @a2
    end
  end
end
