require File.dirname(__FILE__) + '/../test_helper'

class TaskTest < ActiveSupport::TestCase
  context "A Task" do
    setup do
      @obj = Factory :task
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
    
    should "require a component" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :task, :component => nil
      end
    end
  end
end
