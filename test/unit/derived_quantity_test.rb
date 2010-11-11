require 'test_helper'

class DerivedQuantityTest < ActiveSupport::TestCase
  should "be valid" do
    assert DerivedQuantity.new.valid?
  end
end
