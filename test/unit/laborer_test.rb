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
      assert_not_nil @obj.pay_rate
    end
  end
end
