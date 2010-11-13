require File.dirname(__FILE__) + '/../test_helper'

class UnitCostEstimatesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @quantity = Factory :quantity, :value => 1
    @unit_cost_estimate = Factory :unit_cost_estimate, :component => @component, :quantity => @quantity
  end

  test "should get index" do
    get :index, :project_id => @project.to_param, :component_id => @component
    assert_response :success
    assert_not_nil assigns(:unit_cost_estimates)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param, :component_id => @component
    assert_response :success
  end

  test "should create unit_cost_estimate" do
    assert_difference('UnitCostEstimate.count') do
      post :create, :project_id => @project.to_param, :component_id => @component, :unit_cost_estimate => {
        :name => 'blah', :unit_cost => 20, :tax => .0825
      }
    end

    assert_redirected_to project_component_unit_cost_estimate_path(@project, @component, assigns(:unit_cost_estimate))
  end

  test "should show unit_cost_estimate" do
    get :show, :project_id => @project.to_param, :component_id => @component, :id => @unit_cost_estimate.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :component_id => @component, :id => @unit_cost_estimate.to_param
    assert_response :success
  end

  test "should update unit_cost_estimate" do
    put :update, :project_id => @project.to_param, :component_id => @component, :id => @unit_cost_estimate.to_param, :unit_cost_estimate => @unit_cost_estimate.attributes
    assert_redirected_to project_component_unit_cost_estimate_path(@project, @component, assigns(:unit_cost_estimate))
  end

  test "should destroy unit_cost_estimate" do
    assert_difference('UnitCostEstimate.count', -1) do
      delete :destroy, :project_id => @project.to_param, :component_id => @component, :id => @unit_cost_estimate.to_param
    end

    assert_redirected_to project_component_unit_cost_estimates_path(@project, @component)
  end
end
