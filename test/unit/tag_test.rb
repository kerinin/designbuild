require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  context "A Tag" do
    setup do
      @obj = Factory :tag
    end

    teardown do
      Tag.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
    end
  end
end
