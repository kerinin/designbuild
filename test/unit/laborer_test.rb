require 'test_helper'

class LaborerTest < ActiveSupport::TestCase
  should "be valid" do
    assert Laborer.new.valid?
  end
end
