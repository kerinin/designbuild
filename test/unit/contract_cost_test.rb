require 'test_helper'

class ContractCostTest < ActiveSupport::TestCase
  should "be valid" do
    assert ContractCost.new.valid?
  end
end
