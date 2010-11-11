require 'test_helper'

class DeadlineTest < ActiveSupport::TestCase
  should "be valid" do
    assert Deadline.new.valid?
  end
end
