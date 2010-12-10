require File.dirname(__FILE__) + '/../test_helper'

class ContractTest < ActiveSupport::TestCase
  context "A Contract" do
    setup do
      @project = Factory :project
      @pm = Factory :markup, :percent => 100
      @project.markups << @pm
      
      @component = Factory :component, :project => @project
      @cm = Factory :markup, :percent => 100
      @component.markups << @cm
      
      @obj = Factory :contract, :component => @component
      @contract2 = Factory :contract, :project => @project
      
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

    should "allow a component" do
      assert_equal @component, @obj.component
    end
        
    should "allow an active bid" do
      assert_equal @obj.active_bid, @b2
    end
    
    #-------------------Markups
    
    should "inherit project markups" do
      assert_contains @obj.reload.markups, @pm
      assert_contains @contract2.reload.markups, @pm
    end
    
    should "inherit component markups" do
      assert_contains @obj.reload.markups, @cm
    end
    
    should "cascade project markups" do
      @markup = Factory :markup
      @project.markups << @markup
      
      assert_contains @obj.reload.markups, @markup
      assert_contains @contract2.reload.markups, @markup
    end
    
    should "cascade component markups" do
      @markup = Factory :markup
      @component.markups << @markup
      
      assert_contains @obj.reload.markups, @markup
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
      assert_equal 210, @obj.total_markup
    end
  end
end
