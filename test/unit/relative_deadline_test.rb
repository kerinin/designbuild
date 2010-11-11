require 'test_helper'

class RelativeDeadlineTest < ActiveSupport::TestCase
  should "be valid" do
    assert RelativeDeadline.new.valid?
  end
end
