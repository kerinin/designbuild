require 'test_helper'

class PaymentLineTest < ActiveSupport::TestCase
  should "be valid" do
    assert PaymentLine.new.valid?
  end
end
