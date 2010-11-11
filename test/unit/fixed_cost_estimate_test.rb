require 'test_helper'

class FixedCostEstimateTest < ActiveSupport::TestCase
  should "be valid" do
    assert FixedCostEstimate.new.valid?
  end
end
