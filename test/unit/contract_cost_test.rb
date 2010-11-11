require File.dirname(__FILE__) + '/../test_helper'

class ContractCostTest < ActiveSupport::TestCase
  context "A Contract Cost" do
    setup do
      @obj = Factory :contract_cost
    end

    teardown do
      ContractCost.delete_all
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.date
      assert_not_nil @obj.amount
    end
  end
end
