require 'test_helper'

class MaterialCostTest < ActiveSupport::TestCase
  should "be valid" do
    assert MaterialCost.new.valid?
  end
end
