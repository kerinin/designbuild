require File.dirname(__FILE__) + '/../test_helper'

class DatePointTest < ActiveSupport::TestCase
  context "A Date Point" do
    setup do
      @project = Factory :project
      @component = Factory :component
      @task = Factory :task
      @contract = Factory :contract
      
      @p_p = @project.estimated_cost_points.create! :date => Date::today - 5, :value => 100
    end
  end
end
