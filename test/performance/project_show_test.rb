require File.dirname(__FILE__) + '/../test_helper'
require 'rails/performance_test_help'
require File.dirname(__FILE__) + '/../performance_test_helper'



class ProjectShowTest < ActionDispatch::PerformanceTest
  setup do
    post '/users/sign_in', :user => {:email => 'ryan@bcarc.com', :password => 'kundera'}
  end
  
  def test_project_2_show
    get '/projects/2'
  end
  
  def test_project_1_show
    get '/projects/1'
  end
end
