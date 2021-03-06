require File.dirname(__FILE__) + '/../test_helper'

class BidTest < ActiveSupport::TestCase
  context "A bid" do
    setup do
      @project = Factory.build :project
      @component = @project.components.build :name => 'component', :project => @project
      @contract = @component.contracts.build( :name => 'contract', :project => @project, :component => @component )
      @bid = @contract.bids.build( :contractor => 'foo', :date => Date::today, :raw_cost => 100, :contract => @contract)
      @active = @contract.bids.build( :contractor => 'foo', :date => Date::today, :raw_cost => 100, :contract => @contract)
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
      [@project, @component, @contract, @bid, @active].each {|i| i.save!}
      @contract.update_attributes :active_bid => @active
      
      assert_equal @active.reload.is_active_bid, true
      assert_equal @bid.is_active_bid, false
    end
    
    should "set active" do
      [@project, @component, @contract, @bid, @active].each {|i| i.save!}
      @contract.update_attributes :active_bid => @active
      
      @bid.is_active_bid = true
      assert_equal @active.is_active_bid, false
      assert_equal @bid.is_active_bid, true
    end
  end
end
