require File.dirname(__FILE__) + '/../test_helper'

class MaterialCostsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @supplier = Factory :supplier
    @task = Factory :task, :project => @project
    @material_cost = Factory :material_cost, :task => @task
  end

  test "should get index" do
    get :index, :task_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:material_costs)
  end

  test "should get new" do
    get :new, :task_id => @project.to_param
    assert_response :success
  end
  
  
  test "should get xhr new" do
    xhr :get, :new, :task_id => @task.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end

  test "should create material_cost" do
    assert_difference('MaterialCost.count') do
      post :create, :task_id => @project.to_param, :material_cost => {
        :date => '1/1/2000', :cost => 100, :supplier => @supplier
      }
    end

    assert_redirected_to task_material_cost_path(@task, assigns(:material_cost))
  end
  
  test "should create xhr material_cost" do
    assert_difference('MaterialCost.count') do
      xhr :post, :create, :task_id => @project.to_param, :material_cost => {
        :date => '1/1/2000', :cost => 100, :supplier => @supplier
      }
    end
    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should fail to create xhr material_cost" do
    assert_no_difference('MaterialCost.count') do
      xhr :post, :create, :task_id => @project.to_param, :material_cost => {
        :cost => 100, :supplier => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
  end

  test "should show material_cost" do
    get :show, :task_id => @project.to_param, :id => @material_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :task_id => @project.to_param, :id => @material_cost.to_param
    assert_response :success
  end

  test "should update material_cost" do
    put :update, :task_id => @project.to_param, :id => @material_cost.to_param, :material_cost => @material_cost.attributes
    assert_redirected_to project_task_path(@project, @task)
  end

  test "should destroy material_cost" do
    assert_difference('MaterialCost.count', -1) do
      delete :destroy, :task_id => @project.to_param, :id => @material_cost.to_param
    end

    assert_redirected_to task_material_costs_path(@task)
  end
end
