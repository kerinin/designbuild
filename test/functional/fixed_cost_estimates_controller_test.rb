require 'test_helper'

class FixedCostEstimatesControllerTest < ActionController::TestCase
  setup do
    @fixed_cost_estimate = fixed_cost_estimates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:fixed_cost_estimates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create fixed_cost_estimate" do
    assert_difference('FixedCostEstimate.count') do
      post :create, :fixed_cost_estimate => @fixed_cost_estimate.attributes
    end

    assert_redirected_to fixed_cost_estimate_path(assigns(:fixed_cost_estimate))
  end

  test "should show fixed_cost_estimate" do
    get :show, :id => @fixed_cost_estimate.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @fixed_cost_estimate.to_param
    assert_response :success
  end

  test "should update fixed_cost_estimate" do
    put :update, :id => @fixed_cost_estimate.to_param, :fixed_cost_estimate => @fixed_cost_estimate.attributes
    assert_redirected_to fixed_cost_estimate_path(assigns(:fixed_cost_estimate))
  end

  test "should destroy fixed_cost_estimate" do
    assert_difference('FixedCostEstimate.count', -1) do
      delete :destroy, :id => @fixed_cost_estimate.to_param
    end

    assert_redirected_to fixed_cost_estimates_path
  end
end
