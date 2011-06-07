require File.dirname(__FILE__) + '/../test_helper'

class ResourceTest < ActiveSupport::TestCase
  context "A Resource" do
    setup do
      @project = Factory.build :project
      @resource = Factory.build :resource
      
      @obj = Factory.build :resource
      
      @rr1 = @obj.resource_requests.build :project => @project, :resources => [@resource]
      @rr2 = @obj.resource_requests.build :project => @project, :resources => [@resource]
      
      @ra1 = @obj.resource_allocations.build :resource_request => @rr1, :start_date => Date::today, :duration => 1
      @ra2 = @obj.resource_allocations.build :resource_request => @rr1, :start_date => Date::today, :duration => 1
    end
    
    should "be valid" do
      @obj.save!
      assert @obj.valid?
    end
    
    should "require a name" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :resource, :name => nil
      end
    end
    
    should "have associated resource requests" do
      assert_contains @obj.resource_requests, @rr1
      assert_contains @obj.resource_requests, @rr2
    end
    
    should "have associated resource allocations" do
      assert_contains @obj.resource_allocations, @ra1
      assert_contains @obj.resource_allocations, @ra2
    end
  end
end
