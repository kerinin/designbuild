require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  should "be valid" do
    assert Payment.new.valid?
  end
end
