require 'test_helper'

class InvoiceMarkupLineTest < ActiveSupport::TestCase
  should "be valid" do
    assert InvoiceMarkupLine.new.valid?
  end
end
