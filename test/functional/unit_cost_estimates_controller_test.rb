require 'test_helper'

class UnitCostEstimatesControllerTest < ActionController::TestCase
  setup do
    @unit_cost_estimate = unit_cost_estimates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:unit_cost_estimates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create unit_cost_estimate" do
    assert_difference('UnitCostEstimate.count') do
      post :create, :unit_cost_estimate => @unit_cost_estimate.attributes
    end

    assert_redirected_to unit_cost_estimate_path(assigns(:unit_cost_estimate))
  end

  test "should show unit_cost_estimate" do
    get :show, :id => @unit_cost_estimate.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @unit_cost_estimate.to_param
    assert_response :success
  end

  test "should update unit_cost_estimate" do
    put :update, :id => @unit_cost_estimate.to_param, :unit_cost_estimate => @unit_cost_estimate.attributes
    assert_redirected_to unit_cost_estimate_path(assigns(:unit_cost_estimate))
  end

  test "should destroy unit_cost_estimate" do
    assert_difference('UnitCostEstimate.count', -1) do
      delete :destroy, :id => @unit_cost_estimate.to_param
    end

    assert_redirected_to unit_cost_estimates_path
  end
end
