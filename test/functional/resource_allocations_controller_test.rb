require 'test_helper'

class ResourceAllocationsControllerTest < ActionController::TestCase
  setup do
    @resource_allocation = resource_allocations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:resource_allocations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create resource_allocation" do
    assert_difference('ResourceAllocation.count') do
      post :create, :resource_allocation => @resource_allocation.attributes
    end

    assert_redirected_to resource_allocation_path(assigns(:resource_allocation))
  end

  test "should show resource_allocation" do
    get :show, :id => @resource_allocation.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @resource_allocation.to_param
    assert_response :success
  end

  test "should update resource_allocation" do
    put :update, :id => @resource_allocation.to_param, :resource_allocation => @resource_allocation.attributes
    assert_redirected_to resource_allocation_path(assigns(:resource_allocation))
  end

  test "should destroy resource_allocation" do
    assert_difference('ResourceAllocation.count', -1) do
      delete :destroy, :id => @resource_allocation.to_param
    end

    assert_redirected_to resource_allocations_path
  end
end
