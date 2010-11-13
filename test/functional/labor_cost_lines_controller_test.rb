require File.dirname(__FILE__) + '/../test_helper'

class LaborCostLinesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @task = Factory :task, :project => @project
    @labor_cost = Factory :labor_cost, :task => @task
    @labor_cost_line = Factory :labor_cost_line, :labor_set => @labor_cost
  end

  test "should get index" do
    get :index, :project_id => @project.to_param, :task_id => @task.to_param
    assert_response :success
    assert_not_nil assigns(:labor_cost_lines)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param, :task_id => @task.to_param
    assert_response :success
  end

  test "should create labor_cost_line" do
    assert_difference('LaborCostLine.count') do
      post :create, :project_id => @project.to_param, :task_id => @task.to_param, :labor_cost_line => {
        :hours => 8
      }
    end

    assert_redirected_to project_task_labor_cost_line_path(@project, @task, assigns(:labor_cost_line))
  end

  test "should show labor_cost_line" do
    get :show, :project_id => @project.to_param, :task_id => @task.to_param, :id => @labor_cost_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :task_id => @task.to_param, :id => @labor_cost_line.to_param
    assert_response :success
  end

  test "should update labor_cost_line" do
    put :update, :project_id => @project.to_param, :task_id => @task.to_param, :id => @labor_cost_line.to_param, :labor_cost_line => @labor_cost_line.attributes
    assert_redirected_to project_task_labor_cost_line_path(@project, @task, assigns(:labor_cost_line))
  end

  test "should destroy labor_cost_line" do
    assert_difference('LaborCostLine.count', -1) do
      delete :destroy, :project_id => @project.to_param, :task_id => @task.to_param, :id => @labor_cost_line.to_param
    end

    assert_redirected_to project_task_labor_cost_lines_path(@project, @task)
  end
end
