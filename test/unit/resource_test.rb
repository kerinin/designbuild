require File.dirname(__FILE__) + '/../test_helper'

class ResourceTest < ActiveSupport::TestCase
  context "A Resource" do
    setup do
      @obj = Factory :resource
    end
    
    should "be valid" do
      assert @obj.valid?
    end
  end
end
