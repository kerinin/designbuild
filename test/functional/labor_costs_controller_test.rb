require File.dirname(__FILE__) + '/../test_helper'

class LaborCostsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @task = Factory :task, :project => @project
    @labor_cost = Factory :labor_cost, :task => @task
  end

  test "should get index" do
    get :index, :task_id => @task.to_param
    assert_response :success
    assert_not_nil assigns(:labor_costs)
  end

  test "should get new" do
    get :new, :task_id => @task.to_param
    assert_response :success
  end
  
  test "should get xhr new" do
    xhr :get, :new, :task_id => @task.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end

  test "should create labor_cost" do
    assert_difference('LaborCost.count') do
      post :create, :task_id => @task.to_param, :labor_cost => {
        :date => '1/1/2000', :percent_complete => 10
      }
    end

    assert_redirected_to task_labor_cost_path(@task, assigns(:labor_cost))
  end

  test "should create xhr material_cost" do
    assert_difference('MaterialCost.count') do
      xhr :post, :create, :task_id => @project.to_param, :labor_cost => {
        :date => '1/1/2000', :percent_complete => 10
      }
    end
    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should fail to create xhr material_cost" do
    assert_no_difference('MaterialCost.count') do
      xhr :post, :create, :task_id => @project.to_param, :labor_cost => {
        :date => '1/1/2000', :percent_complete => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should show labor_cost" do
    get :show, :task_id => @task.to_param, :id => @labor_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :task_id => @task.to_param, :id => @labor_cost.to_param
    assert_response :success
  end

  test "should update labor_cost" do
    put :update, :task_id => @task.to_param, :id => @labor_cost.to_param, :labor_cost => @labor_cost.attributes
    assert_redirected_to task_labor_cost_path(@task, assigns(:labor_cost))
  end

  test "should destroy labor_cost" do
    assert_difference('LaborCost.count', -1) do
      delete :destroy, :task_id => @task.to_param, :id => @labor_cost.to_param
    end

    assert_redirected_to task_labor_costs_path(@task)
  end
end
