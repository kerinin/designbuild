require 'test_helper'

class LaborCostsControllerTest < ActionController::TestCase
  setup do
    @labor_cost = labor_costs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:labor_costs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create labor_cost" do
    assert_difference('LaborCost.count') do
      post :create, :labor_cost => @labor_cost.attributes
    end

    assert_redirected_to labor_cost_path(assigns(:labor_cost))
  end

  test "should show labor_cost" do
    get :show, :id => @labor_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @labor_cost.to_param
    assert_response :success
  end

  test "should update labor_cost" do
    put :update, :id => @labor_cost.to_param, :labor_cost => @labor_cost.attributes
    assert_redirected_to labor_cost_path(assigns(:labor_cost))
  end

  test "should destroy labor_cost" do
    assert_difference('LaborCost.count', -1) do
      delete :destroy, :id => @labor_cost.to_param
    end

    assert_redirected_to labor_costs_path
  end
end
