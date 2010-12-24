require 'test_helper'
require 'rails/performance_test_help'

class LaborSummaryTest < ActionDispatch::PerformanceTest
  # Replace this with your real tests.
  setup do
    sign_in Factory :user
  end
  
  def test_labor_summary
    get '/projects/labor_summary'
  end
  
  def test_project_labor_summary
    get '/projects/2/labor_summary'
  end
end
