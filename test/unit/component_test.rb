require File.dirname(__FILE__) + '/../test_helper'

class ComponentTest < ActiveSupport::TestCase
  context "A component" do
    setup do
      @obj = Factory :component
    end

    teardown do
      Component.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
    end
  end
end
