require 'test_helper'

class ResourceRequestsControllerTest < ActionController::TestCase
  setup do
    @resource_request = resource_requests(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_requests)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_request" do
    assert_difference('ResourceRequest.count') do
      post :create, :resource_request => @resource_request.attributes
    end

    assert_redirected_to resource_request_path(assigns(:resource_request))
  end

  test "should show resource_request" do
    get :show, :id => @resource_request.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @resource_request.to_param
    assert_response :success
  end

  test "should update resource_request" do
    put :update, :id => @resource_request.to_param, :resource_request => @resource_request.attributes
    assert_redirected_to resource_request_path(assigns(:resource_request))
  end

  test "should destroy resource_request" do
    assert_difference('ResourceRequest.count', -1) do
      delete :destroy, :id => @resource_request.to_param
    end

    assert_redirected_to resource_requests_path
  end
end
