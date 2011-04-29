require 'test_helper'

class PaymentMarkupLineTest < ActiveSupport::TestCase
  should "be valid" do
    assert PaymentMarkupLine.new.valid?
  end
end
