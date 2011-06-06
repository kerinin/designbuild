require File.dirname(__FILE__) + '/../test_helper'

class ResourceAllocationTest < ActiveSupport::TestCase
  context "A Resource Allocation" do
    setup do
      @obj = Factory :resource_allocation
    end
    
    should "be valid" do
      assert @obj.valid?
    end
  end
end
