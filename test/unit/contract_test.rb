require File.dirname(__FILE__) + '/../test_helper'

class ContractTest < ActiveSupport::TestCase
  context "A Contract" do
    setup do
      @obj = Factory :contract, :bid => 100
      
      @c1 = Factory :contract_cost, :contract => @obj, :cost => 1
      @c2 = Factory :contract_cost, :contract => @obj, :cost => 10
      @b1 = Factory :bid, :contract => @obj
      @b2 = Factory :bid, :contract => @obj
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
    
    should "require a project" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :contract, :project => nil
      end
    end
    
    should "allow multiple costs" do
      assert_contains @obj.costs, @c1
      assert_contains @obj.costs, @c2
    end
    
    should "allow multiple bids" do
      assert_contains @obj.bids, @b1
      assert_contains @obj.bids, @b2
    end
    
    #-------------------CALCULATIONS
    
    should "aggregate costs" do
      assert_equal 11, @obj.cost
    end
  end
end
