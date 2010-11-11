require 'test_helper'

class UnitCostEstimateTest < ActiveSupport::TestCase
  should "be valid" do
    assert UnitCostEstimate.new.valid?
  end
end
