require File.dirname(__FILE__) + '/../test_helper'

class RelativeDeadlineTest < ActiveSupport::TestCase
  context "A Relative Deadline" do
    setup do
      @parent = Deadline.new
      @obj = RelativeDeadline.new :name => 'test', :interval => 10, :parent_deadline => @parent #Factory :relative_deadline
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
  end
end
