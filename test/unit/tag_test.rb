require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  context "A Tag" do
    setup do
      @obj = Factory :tag
      
      @c1 = Factory :component, :tags => [@obj]
      @c2 = Factory :component, :tags => [@obj]
    end

    teardown do
      Tag.delete_all
      Component.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
    end
    
    should "have multiple components" do
      assert_contains @obj.components, @c1
      assert_contains @obj.components, @c2
      assert_contains @c1.tags, @obj
      assert_contains @c2.tags, @obj
    end
  end
end
