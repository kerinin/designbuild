require 'test_helper'

class LaborCostLineTest < ActiveSupport::TestCase
  should "be valid" do
    assert LaborCostLine.new.valid?
  end
end
