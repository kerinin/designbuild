require File.dirname(__FILE__) + '/../test_helper'

class ResourcesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @resource = Factory :resource
    
    @request1 = @resource.resource_requests.build :project => @project, :resource => @resource
    @request2 = @resource.resource_requests.build :project => @project, :resource => @resource
    
    @allocation1 = @resource.resource_allocations.build :resource_request => @request1, :start_date => Date::today, :duration => 1
    @allocation2 = @resource.resource_allocations.build :resource_request => @request2, :start_date => Date::today, :duration => 1
    
    sign_in Factory :user
  end
  
  test "should route correctly" do
    assert_routing '/resources', { :controller => "resources", :action => "index" }
    assert_routing '/resources/1', { :controller => "resources", :action => "show", :id => "1" }
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resources)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource" do
    assert_difference('Resource.count') do
      post :create, :resource => @resource.attributes
    end

    assert_redirected_to resource_path(assigns(:resource))
  end

  test "should show resource" do
    get :show, :id => @resource.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @resource.to_param
    assert_response :success
  end

  test "should update resource" do
    put :update, :id => @resource.to_param, :resource => @resource.attributes
    assert_redirected_to resource_path(assigns(:resource))
  end

  test "should destroy resource" do
    assert_difference('Resource.count', -1) do
      delete :destroy, :id => @resource.to_param
    end

    assert_redirected_to resources_path
  end
end
