require 'test_helper'

class ProjectsUsersTest < ActiveSupport::TestCase
  should "be valid" do
    assert ProjectsUsers.new.valid?
  end
end
