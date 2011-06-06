require File.dirname(__FILE__) + '/../test_helper'

class ResourceAllocationTest < ActiveSupport::TestCase
  context "A Resource Allocation" do
    setup do
      @project = Factory.build :project
      @resource = Factory.build :resource
      @resource_request = Factory.build :resource_request
      
      @obj = Factory :resource_allocation, :resource_request => @resource_request
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "require values" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :resource_allocation, :start_date => nil
      end
      
      assert_raise ActiveRecord::RecordInvalid do
        Factory :resource_allocation, :duration => nil
      end
    end
    
    should "require associated resource request" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :resource_allocation, :resource_request => nil
      end
      
      assert_equal @resource_request, @obj.resource_request
    end
  end
end
