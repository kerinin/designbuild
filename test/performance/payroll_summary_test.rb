require File.dirname(__FILE__) + '/../test_helper'
#require 'test_helper'
#require File.dirname(__FILE__) + '/../rails/performance_test_help'
require 'rails/performance_test_help'
require File.dirname(__FILE__) + '/../performance_test_helper'
#require 'performance_test_helper'


class PayrollSummaryTest < ActionDispatch::PerformanceTest
  setup do
    post '/users/sign_in', :user => {:email => 'ryan@bcarc.com', :password => 'kundera'}
  end
  
  def test_payroll_summary
    get '/projects/payroll_summary'
  end
  
  def test_project_payroll_summary
    get '/projects/2/payroll_summary'
  end
end
