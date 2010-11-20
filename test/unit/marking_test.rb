require 'test_helper'

class MarkingTest < ActiveSupport::TestCase
  should "be valid" do
    assert Marking.new.valid?
  end
end
