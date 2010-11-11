require File.dirname(__FILE__) + '/../test_helper'

class BidTest < ActiveSupport::TestCase
  context "A bid" do
    setup do
      @bid = Factory :bid
    end

    teardown do
      Bid.delete_all
      Contract.delete_all
    end
    
    should "be valid" do
      assert @bid.valid?
    end
    
    should "have values" do
      assert_not_nil @bid.date
      assert_not_nil @bid.amount
    end
  end
end
