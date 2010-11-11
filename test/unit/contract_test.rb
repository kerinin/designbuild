require File.dirname(__FILE__) + '/../test_helper'

class ContractTest < ActiveSupport::TestCase
  context "A Contract" do
    setup do
      @obj = Factory :contract
    end

    teardown do
      Contract.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.contractor
      assert_not_nil @obj.bid
    end
  end
end
