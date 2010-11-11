require 'test_helper'

class QuantityTest < ActiveSupport::TestCase
  should "be valid" do
    assert Quantity.new.valid?
  end
end
