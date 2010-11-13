require File.dirname(__FILE__) + '/../test_helper'

class MaterialCostsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @task = Factory :task, :project => @project
    @material_cost = Factory :material_cost, :task => @task
  end

  test "should get index" do
    get :index, :project_id => @project.to_param, :task_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:material_costs)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param, :task_id => @project.to_param
    assert_response :success
  end

  test "should create material_cost" do
    assert_difference('MaterialCost.count') do
      post :create, :project_id => @project.to_param, :task_id => @project.to_param, :material_cost => {
        :date => '1/1/2000', :cost => 100
      }
    end

    assert_redirected_to project_task_material_cost_path(@project, @task, assigns(:material_cost))
  end

  test "should show material_cost" do
    get :show, :project_id => @project.to_param, :task_id => @project.to_param, :id => @material_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :task_id => @project.to_param, :id => @material_cost.to_param
    assert_response :success
  end

  test "should update material_cost" do
    put :update, :project_id => @project.to_param, :task_id => @project.to_param, :id => @material_cost.to_param, :material_cost => @material_cost.attributes
    assert_redirected_to project_task_material_cost_path(@project, @task, assigns(:material_cost))
  end

  test "should destroy material_cost" do
    assert_difference('MaterialCost.count', -1) do
      delete :destroy, :project_id => @project.to_param, :task_id => @project.to_param, :id => @material_cost.to_param
    end

    assert_redirected_to project_task_material_costs_path(@project, @task)
  end
end
