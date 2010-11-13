require File.dirname(__FILE__) + '/../test_helper'

class LaborerTest < ActiveSupport::TestCase
  context "A Laborer" do
    setup do
      @obj = Factory :laborer
    end

    teardown do
      Laborer.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
      assert_not_nil @obj.bill_rate
    end
    
    should "require a project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :laborer, :project => nil
      end
    end
  end
end
