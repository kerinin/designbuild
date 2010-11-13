require File.dirname(__FILE__) + '/../test_helper'

class FixedCostEstimatesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @fixed_cost_estimate = Factory :fixed_cost_estimate, :component => @component
  end

  test "should get index" do
    get :index, :component_id => @component.to_param
    assert_response :success
    assert_not_nil assigns(:fixed_cost_estimates)
  end

  test "should get new" do
    get :new, :component_id => @component.to_param
    assert_response :success
  end

  test "should create fixed_cost_estimate" do
    assert_difference('FixedCostEstimate.count') do
      post :create, :component_id => @component.to_param, :fixed_cost_estimate => {
        :name => 'blah', :cost => 20
      }
    end

    assert_redirected_to component_fixed_cost_estimate_path(@component, assigns(:fixed_cost_estimate))
  end

  test "should show fixed_cost_estimate" do
    get :show, :component_id => @component.to_param, :id => @fixed_cost_estimate.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :component_id => @component.to_param, :id => @fixed_cost_estimate.to_param
    assert_response :success
  end

  test "should update fixed_cost_estimate" do
    put :update, :component_id => @component.to_param, :id => @fixed_cost_estimate.to_param, :fixed_cost_estimate => @fixed_cost_estimate.attributes
    assert_redirected_to component_fixed_cost_estimate_path(@component, assigns(:fixed_cost_estimate))
  end

  test "should destroy fixed_cost_estimate" do
    assert_difference('FixedCostEstimate.count', -1) do
      delete :destroy, :component_id => @component.to_param, :id => @fixed_cost_estimate.to_param
    end

    assert_redirected_to component_fixed_cost_estimates_path(@component)
  end
end
