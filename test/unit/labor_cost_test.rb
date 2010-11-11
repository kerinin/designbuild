require 'test_helper'

class LaborCostTest < ActiveSupport::TestCase
  should "be valid" do
    assert LaborCost.new.valid?
  end
end
