require 'test_helper'

class LaborCostLinesControllerTest < ActionController::TestCase
  setup do
    @labor_cost_line = labor_cost_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:labor_cost_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create labor_cost_line" do
    assert_difference('LaborCostLine.count') do
      post :create, :labor_cost_line => @labor_cost_line.attributes
    end

    assert_redirected_to labor_cost_line_path(assigns(:labor_cost_line))
  end

  test "should show labor_cost_line" do
    get :show, :id => @labor_cost_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @labor_cost_line.to_param
    assert_response :success
  end

  test "should update labor_cost_line" do
    put :update, :id => @labor_cost_line.to_param, :labor_cost_line => @labor_cost_line.attributes
    assert_redirected_to labor_cost_line_path(assigns(:labor_cost_line))
  end

  test "should destroy labor_cost_line" do
    assert_difference('LaborCostLine.count', -1) do
      delete :destroy, :id => @labor_cost_line.to_param
    end

    assert_redirected_to labor_cost_lines_path
  end
end
