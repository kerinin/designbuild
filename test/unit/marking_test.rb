require 'test_helper'

class MarkingTest < ActiveSupport::TestCase
  context "A Markup" do
    setup do
      @obj = Factory :markup
    end
    
    should "be valid" do
      assert @obj.valid?
    end
  end
end
