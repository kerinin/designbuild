require File.dirname(__FILE__) + '/../test_helper'

class ContractCostTest < ActiveSupport::TestCase
  context "A Contract Cost" do
    setup do
      @obj = Factory.build :contract_cost
    end
    
    should "be valid" do
      assert @obj.valid?
    end
    
    should "have values" do
      assert_not_nil @obj.date
      assert_not_nil @obj.raw_cost
    end
    
    should "require a contract" do
      assert_raise ActiveRecord::RecordInvalid do
        Factory :contract_cost, :contract => nil
      end
    end
  end
end
