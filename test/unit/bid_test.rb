require File.dirname(__FILE__) + '/../test_helper'

class BidTest < ActiveSupport::TestCase
  context "A bid" do
    setup do
      @contract = Factory :contract
      @bid = Factory :bid, :contract => @contract
      @active = Factory :bid, :contract => @contract
      @contract.active_bid = @active
      @contract.save!
      
      @contract.reload
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
      assert_not_nil @bid.raw_cost
    end
    
    should "require a contract" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :bid, :contract => nil
      end
    end
    
    should "check if active" do
      assert_equal @active.is_active_bid, true
      assert_equal @bid.is_active_bid, false
    end
    
    should "set active" do
      @bid.is_active_bid = true
      assert_equal @active.is_active_bid, false
      assert_equal @bid.is_active_bid, true
    end
  end
end
