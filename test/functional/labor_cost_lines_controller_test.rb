require File.dirname(__FILE__) + '/../test_helper'

class LaborCostLinesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @laborer = Factory :laborer, :project => @project
    @task = Factory :task, :project => @project
    @labor_cost = Factory :labor_cost, :task => @task
    @labor_cost_line = Factory :labor_cost_line, :labor_set => @labor_cost
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :labor_cost_id => @labor_cost.to_param
    assert_response :success
    assert_not_nil assigns(:labor_cost_lines)
  end

  test "should get new" do
    get :new, :labor_cost_id => @labor_cost.to_param
    assert_response :success
  end

  test "should xhr get new" do
    xhr :get, :new, :labor_cost_id => @labor_cost.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should create labor_cost_line" do
    assert_difference('LaborCostLine.count') do
      post :create, :labor_cost_id => @labor_cost.to_param, :labor_cost_line => {
        :hours => 8, :laborer_id => @laborer
      }
    end

    assert_redirected_to labor_cost_line_item_path(@labor_cost, assigns(:labor_cost_line))
  end

  test "should xhr create labor cost line" do
    assert_difference('LaborCostLine.count') do
      xhr :post, :create, :labor_cost_id => @labor_cost.to_param, :labor_cost_line => {
        :hours => 8, :laborer_id => @laborer
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr labor cost line" do
    assert_no_difference('LaborCostLine.count') do
      xhr :post, :create, :labor_cost_id => @labor_cost.to_param, :labor_cost_line => {
        :hours => nil, :laborer_id => @laborer
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show labor_cost_line" do
    get :show, :labor_cost_id => @labor_cost.to_param, :id => @labor_cost_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :labor_cost_id => @labor_cost.to_param, :id => @labor_cost_line.to_param
    assert_response :success
  end

  test "should xhr get edit" do
    xhr :get, :edit, :labor_cost_id => @labor_cost.to_param, :id => @labor_cost_line.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should update labor_cost_line" do
    put :update, :labor_cost_id => @labor_cost.to_param, :id => @labor_cost_line.to_param, :labor_cost_line => @labor_cost_line.attributes
    assert_redirected_to labor_cost_line_item_path(@labor_cost, assigns(:labor_cost_line))
  end

  test "should xhr update labor cost line" do
    xhr :put, :update, :labor_cost_id => @labor_cost.to_param, :id => @labor_cost_line.to_param, :labor_cost_line => @labor_cost_line.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update labor cost line" do
    xhr :put, :update, :labor_cost_id => @labor_cost.to_param, :id => @labor_cost_line.to_param, :labor_cost_line => {
        :hours => nil, :laborer_id => @laborer
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should destroy labor_cost_line" do
    assert_difference('LaborCostLine.count', -1) do
      delete :destroy, :labor_cost_id => @labor_cost.to_param, :id => @labor_cost_line.to_param
    end

    assert_redirected_to task_labor_cost_path(@task, @labor_cost)
  end
end
