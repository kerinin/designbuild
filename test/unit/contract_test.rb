require File.dirname(__FILE__) + '/../test_helper'

class ContractTest < ActiveSupport::TestCase
  context "A Contract" do
    setup do
      @obj = Factory :contract
      
      @c1 = Factory :contract_cost, :contract => @obj, :raw_cost => 1
      @c2 = Factory :contract_cost, :contract => @obj, :raw_cost => 10
      @b1 = Factory :bid, :contract => @obj
      @b2 = Factory :bid, :contract => @obj, :raw_cost => 100
      @obj.active_bid = @b2
      @obj.save
    end

    teardown do
      Contract.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.name
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
    
    should "allow an active bid" do
      assert_equal @obj.active_bid, @b2
    end
    
    #-------------------CALCULATIONS
 
    should "return current bid cost" do
      assert_equal 100, @obj.raw_cost
    end
       
    should "aggregate invoiced costs" do
      assert_equal 11, @obj.raw_invoiced
    end
    
    should "update total markup after add" do
      @markup = Factory :markup, :percent => 10
      @obj.markups << @markup
      assert_equal 10, @obj.total_markup
    end
  end
end
