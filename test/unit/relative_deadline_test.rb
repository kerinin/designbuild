require File.dirname(__FILE__) + '/../test_helper'

class RelativeDeadlineTest < ActiveSupport::TestCase
  context "A Relative Deadline" do
    setup do
      @obj = Factory :relative_deadline
    end

    teardown do
      RelativeDeadline.delete_all
      Deadline.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.interval
    end
    
    should "require a parent deadline" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :relative_deadline, :parent_deadline => nil
      end
    end
  end
end
