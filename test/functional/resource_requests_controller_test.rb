require 'test_helper'

class ResourceRequestsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @resource = Factory :resource
    
    @request1 = @resource.resource_requests.create :project => @project, :resource => @resource, :duration => 4
    @request2 = @resource.resource_requests.create :project => @project, :resource => @resource, :duration => 4
    
    @allocation1 = @resource.resource_allocations.build :resource_request => @request1, :start_date => Date::today, :duration => 1
    @allocation2 = @resource.resource_allocations.build :resource_request => @request2, :start_date => Date::today, :duration => 1
    
    sign_in Factory :user
  end

  test "should route correctly" do
    assert_recognizes({ :controller => "resource_requests", :action => "index", :project_id => "1" }, '/projects/1/resource_requests')
    assert_recognizes({ :controller => "resource_requests", :action => "show", :project_id => "1", :id => "2" }, '/projects/1/resource_requests/2')
  end
  
  test "should get index from project" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:resource_requests)
    assert_not_nil assigns(:project)
  end

  test "should get new from project" do
    get :new, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:resource_request)
    assert_not_nil assigns(:project)
  end
  
  test "should get xhr new" do
    xhr :get, :new, :resource_request => {:resource_id => @resource.id, :resource_allocations_attributes => [ {:start_date => Date::today.to_s, :duration => 1 } ] }
    assert_response :success
    assert_not_nil assigns(:resource_request)
    assert !assigns(:resource_request).resource_allocations.empty?
  end
    
  test "should create resource_request from project" do
    assert_difference('ResourceRequest.count') do
      post :create, :project_id => @project.to_param, :resource_request => @request1.attributes
    end

    assert_redirected_to resource_resource_allocations_path(assigns(:resource_request).resource)
  end

  test "should create xhr resource_request" do
    xhr :post, :create, :resource_request => {:resource_id => @resource.id, :resource_allocations_attributes => [ {:start_date => Date::today.to_s, :duration => 1 } ] }
    assert_response :success
    assert_not_nil assigns(:resource_request)
    assert !assigns(:resource_request).resource_allocations.empty?
  end
  
  test "should show resource_request from project" do
    get :show, :project_id => @project.to_param, :id => @request1.to_param
    assert_response :success
    assert_not_nil assigns(:resource_request)
    assert_not_nil assigns(:project)
  end

  test "should get edit from project" do
    get :edit, :project_id => @project.to_param, :id => @request1.to_param
    assert_response :success
    assert_not_nil assigns(:resource_request)
    assert_not_nil assigns(:project)
  end

  test "should update resource_request from project" do
    put :update, :project_id => @project.to_param, :id => @request1.to_param, :resource_request => @request1.attributes
    assert_redirected_to resource_resource_allocations_path(assigns(:resource_request).resource)
  end

  test "should destroy resource_request from project" do
    assert_difference('ResourceRequest.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @request1.to_param
    end

    assert_redirected_to project_resource_requests_path(@project)
  end
end
