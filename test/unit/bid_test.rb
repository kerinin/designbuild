require 'test_helper'

class BidTest < ActiveSupport::TestCase
  should "be valid" do
    assert Bid.new.valid?
  end
end
