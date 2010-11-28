require File.dirname(__FILE__) + '/../test_helper'

class MaterialCostLinesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @task = Factory :task, :project => @project
    @material_cost = Factory :material_cost, :task => @task
    @material_cost_line = Factory :material_cost_line, :material_set => @material_cost
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :material_cost_id => @material_cost.to_param
    assert_response :success
    assert_not_nil assigns(:material_cost_lines)
  end

  test "should get new" do
    get :new, :material_cost_id => @material_cost.to_param
    assert_response :success
  end

  test "should xhr get new" do
    xhr :get, :new, :material_cost_id => @material_cost.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should create material_cost_line" do
    assert_difference('MaterialCostLine.count') do
      post :create, :material_cost_id => @material_cost.to_param, :material_cost_line => {
        :name => 'blah', :quantity => 20
      }
    end

    assert_redirected_to material_cost_line_item_path(@material_cost, assigns(:material_cost_line))
  end

  test "should xhr create material cost line" do
    assert_difference('MaterialCostLine.count') do
      xhr :post, :create, :material_cost_id => @material_cost.to_param, :material_cost_line => {
        :name => 'blah', :quantity => 20
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr material cost line" do
    assert_no_difference('MaterialCostLine.count') do
      xhr :post, :create, :material_cost_id => @material_cost.to_param, :material_cost_line => {
        :name => 'blah', :quantity => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show material_cost_line" do
    get :show, :material_cost_id => @material_cost.to_param, :id => @material_cost_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :material_cost_id => @material_cost.to_param, :id => @material_cost_line.to_param
    assert_response :success
  end

  test "should xhr get edit" do
    xhr :get, :edit, :material_cost_id => @material_cost.to_param, :id => @material_cost_line.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should update material_cost_line" do
    put :update, :material_cost_id => @material_cost.to_param, :id => @material_cost_line.to_param, :material_cost_line => @material_cost_line.attributes
    assert_redirected_to material_cost_line_item_path(@material_cost, assigns(:material_cost_line))
  end

  test "should xhr update material cost line" do
    xhr :put, :update, :material_cost_id => @material_cost.to_param, :id => @material_cost_line.to_param, :material_cost_line => @material_cost_line.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update material cost line" do
    xhr :put, :update, :material_cost_id => @material_cost.to_param, :id => @material_cost_line.to_param, :material_cost_line => {
        :name => 'blah', :quantity => nil
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should destroy material_cost_line" do
    assert_difference('MaterialCostLine.count', -1) do
      delete :destroy, :material_cost_id => @material_cost.to_param, :id => @material_cost_line.to_param
    end

    assert_redirected_to task_material_cost_path(@task, @material_cost)
  end
end
