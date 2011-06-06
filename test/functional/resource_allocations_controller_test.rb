require 'test_helper'

class ResourceAllocationsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @resource = Factory :resource
    
    @request1 = @resource.resource_requests.create :project => @project, :resource => @resource
    @request2 = @resource.resource_requests.create :project => @project, :resource => @resource
    
    @allocation1 = Factory :resource_allocation, :resource_request => @request1, :start_date => Date::today, :duration => 1
    @allocation2 = Factory :resource_allocation, :resource_request => @request1, :start_date => Date::today, :duration => 1
    
    sign_in Factory :user
  end

  test "should route correctly" do
    assert_routing '/resource_allocations', { :controller => "resource_allocations", :action => "index" }
    assert_routing '/resource_allocations/1', { :controller => "resource_allocations", :action => "show", :id => "1" }
    
    assert_recognizes({ :controller => "resource_allocations", :action => "index", :project_id => "1" }, '/projects/1/resource_allocations')
    assert_recognizes({ :controller => "resource_allocations", :action => "show",:project_id => "1", :id => "2" }, '/projects/1/resource_allocations/2')
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
      post :create, :resource_allocation => @allocation1.attributes
    end

    assert_redirected_to resource_allocation_path(assigns(:resource_allocation))
  end

  test "should show resource_allocation" do
    get :show, :id => @allocation1.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @allocation1.to_param
    assert_response :success
  end

  test "should update resource_allocation" do
    put :update, :id => @allocation1.to_param, :resource_allocation => @allocation1.attributes
    assert_redirected_to resource_allocation_path(assigns(:resource_allocation))
  end

  test "should destroy resource_allocation" do
    assert_difference('ResourceAllocation.count', -1) do
      delete :destroy, :id => @allocation1.to_param
    end

    assert_redirected_to resource_allocations_path
  end
  
  # ---------------- FROM PROJECT

  test "should get index from project" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:resource_allocations)
  end

  test "should show resource_allocation from project" do
    get :show, :project_id => @project.to_param, :id => @allocation1.to_param
    assert_response :success
  end
end
