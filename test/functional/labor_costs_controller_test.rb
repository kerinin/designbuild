require File.dirname(__FILE__) + '/../test_helper'

class LaborCostsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @task = Factory :task, :project => @project
    @labor_cost = Factory :labor_cost, :task => @task
    sign_in Factory :user
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
        :date => '1/1/2000', :percent_complete => 10, :note => 'blah'
      }
    end

    assert_redirected_to task_labor_cost_path(@task, assigns(:labor_cost))
  end

  test "should create xhr labor_cost" do
    assert_difference('LaborCost.count') do
      xhr :post, :create, :task_id => @task.to_param, :labor_cost => {
        :date => '1/1/2000', :percent_complete => 10, :note => 'blah'
      }
    end
    
    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr labor_cost" do
    assert_no_difference('LaborCost.count') do
      xhr :post, :create, :task_id => @task.to_param, :labor_cost => {
        :date => '1/1/2000', :percent_complete => nil, :note => 'blah'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
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

    assert_redirected_to project_task_path(@project, @task)
  end
end
