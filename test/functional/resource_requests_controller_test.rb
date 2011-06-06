require 'test_helper'

class ResourceRequestsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @resource = Factory :resource
    
    @request1 = @resource.resource_requests.create :project => @project, :resource => @resource
    @request2 = @resource.resource_requests.create :project => @project, :resource => @resource
    
    @allocation1 = @resource.resource_allocations.build :resource_request => @request1, :start_date => Date::today, :duration => 1
    @allocation2 = @resource.resource_allocations.build :resource_request => @request2, :start_date => Date::today, :duration => 1
    
    sign_in Factory :user
  end

  test "should route correctly" do
    assert_recognizes({ :controller => "resource_requests", :action => "index", :project_id => "1" }, '/projects/1/resource_requests')
    assert_recognizes({ :controller => "resource_requests", :action => "index", :project_id => "1", :id => "2" }, '/projects/1/resource_requests/2')
  end
  
  test "should get index from project" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:resource_requests)
  end

  test "should get new from project" do
    get :new, :project_id => @project.to_param
    assert_response :success
  end

  test "should create resource_request from project" do
    assert_difference('ResourceRequest.count') do
      post :create, :project_id => @project.to_param, :resource_request => @request1.attributes
    end

    assert_redirected_to resource_request_path(assigns(:resource_request))
  end

  test "should show resource_request from project" do
    get :show, :project_id => @project.to_param, :id => @request1.to_param
    assert_response :success
  end

  test "should get edit from project" do
    get :edit, :project_id => @project.to_param, :id => @request1.to_param
    assert_response :success
  end

  test "should update resource_request from project" do
    put :update, :project_id => @project.to_param, :id => @request1.to_param, :resource_request => @request1.attributes
    assert_redirected_to resource_request_path(assigns(:resource_request))
  end

  test "should destroy resource_request from project" do
    assert_difference('ResourceRequest.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @request1.to_param
    end

    assert_redirected_to resource_requests_path
  end
end
