require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  context "A Task" do
    setup do
      @est = Factory :fixed_cost_estimate
      @obj = Factory :task, :estimate => @est
    end

    teardown do
      Task.delete_all
      Component.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
    end
    
    should "allow an estimate" do
      assert_equal @obj.estimate, @est
    end
  end
end
