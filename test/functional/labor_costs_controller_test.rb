require File.dirname(__FILE__) + '/../test_helper'

class LaborCostsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @task = Factory :task, :project => @project
    @labor_cost = Factory :labor_cost, :task => @task
  end

  test "should get index" do
    get :index, :project_id => @project.to_param, :task_id => @task.to_param
    assert_response :success
    assert_not_nil assigns(:labor_costs)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param, :task_id => @task.to_param
    assert_response :success
  end

  test "should create labor_cost" do
    assert_difference('LaborCost.count') do
      post :create, :project_id => @project.to_param, :task_id => @task.to_param, :labor_cost => @labor_cost.attributes
    end

    assert_redirected_to project_task_labor_cost_path(@project, @task, assigns(:labor_cost))
  end

  test "should show labor_cost" do
    get :show, :project_id => @project.to_param, :task_id => @task.to_param, :id => @labor_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :task_id => @task.to_param, :id => @labor_cost.to_param
    assert_response :success
  end

  test "should update labor_cost" do
    put :update, :project_id => @project.to_param, :task_id => @task.to_param, :id => @labor_cost.to_param, :labor_cost => @labor_cost.attributes
    assert_redirected_to project_task_labor_cost_path(@project, @task, assigns(:labor_cost))
  end

  test "should destroy labor_cost" do
    assert_difference('LaborCost.count', -1) do
      delete :destroy, :project_id => @project.to_param, :task_id => @task.to_param, :id => @labor_cost.to_param
    end

    assert_redirected_to project_task_labor_costs_path(@project, @task)
  end
end
