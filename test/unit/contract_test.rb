require 'test_helper'

class ContractTest < ActiveSupport::TestCase
  should "be valid" do
    assert Contract.new.valid?
  end
end
