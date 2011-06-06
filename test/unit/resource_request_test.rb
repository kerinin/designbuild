require File.dirname(__FILE__) + '/../test_helper'

class ResourceRequestTest < ActiveSupport::TestCase
  context "A Resource Request" do
    setup do
      @obj = Factory :resource_request
    end
    
    should "be valid" do
      assert @obj.valid?
    end
  end
end
