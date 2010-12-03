require File.dirname(__FILE__) + '/../test_helper'

class ReportsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    sign_in Factory :user
  end      
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
    assert_not_nil assigns(:laborers)
    assert_not_nil assigns(:material_costs)
    assert_not_nil assigns(:labor_costs)
  end
end
