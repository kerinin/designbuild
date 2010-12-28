require File.dirname(__FILE__) + '/../test_helper'
require 'rails/performance_test_help'
require File.dirname(__FILE__) + '/../performance_test_helper'


class LaborSummaryTest < ActionDispatch::PerformanceTest
  setup do
    post '/users/sign_in', :user => {:email => 'ryan@bcarc.com', :password => 'kundera'}
  end
  
  def test_labor_summary
    get '/projects/labor_summary'
  end
  
  def test_project_labor_summary
    get '/projects/2/labor_summary'
  end
end
