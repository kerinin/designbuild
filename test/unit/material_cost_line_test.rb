require 'test_helper'

class MaterialCostLineTest < ActiveSupport::TestCase
  should "be valid" do
    assert MaterialCostLine.new.valid?
  end
end
