require 'test_helper'

class ComponentTest < ActiveSupport::TestCase
  should "be valid" do
    assert Component.new.valid?
  end
end
