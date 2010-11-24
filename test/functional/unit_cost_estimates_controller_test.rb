require File.dirname(__FILE__) + '/../test_helper'

class UnitCostEstimatesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @quantity = Factory :quantity, :value => 1
    @unit_cost_estimate = Factory :unit_cost_estimate, :component => @component, :quantity => @quantity
  end

  test "should get index" do
    get :index, :component_id => @component
    assert_response :success
    assert_not_nil assigns(:unit_cost_estimates)
  end

  test "should get new" do
    get :new, :component_id => @component
    assert_response :success
  end
  
  test "should get xhr new from component" do
    xhr :get, :new, :component_id => @component
    assert_response(:success)
    assert_template(:new)
  end
  
  test "should get xhr new from project" do
    xhr :get, :new, :component_id => @component, :context => :project
    assert_response(:success)
    assert_template(:new)
  end

  test "should create unit_cost_estimate" do
    assert_difference('UnitCostEstimate.count') do
      post :create, :component_id => @component, :unit_cost_estimate => {
        :quantity_id => @quantity, :name => 'blah', :unit_cost => 20, :drop => 10
      }
    end
    
    assert_redirected_to component_unit_cost_estimate_path(@component, assigns(:unit_cost_estimate))
  end
  
  test "should create xhr unit cost estimate" do
    assert_difference('UnitCostEstimate.count') do
      xhr :post, :create, :component_id => @component, :unit_cost_estimate => {
        :quantity_id => @quantity, :name => 'blah', :unit_cost => 20, :drop => 10
      }
    end
    assert_response(:success)
    assert_template(:create)
  end
  
  test "should show unit_cost_estimate" do
    get :show, :component_id => @component, :id => @unit_cost_estimate.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :component_id => @component, :id => @unit_cost_estimate.to_param
    assert_response :success
  end
  
  test "should get xhr edit" do
    xhr :get, :edit, :component_id => @component, :id => @unit_cost_estimate.to_param
    assert_response :success
    assert_template :edit
  end

  test "should update unit_cost_estimate" do
    put :update, :component_id => @component, :id => @unit_cost_estimate.to_param, :unit_cost_estimate => @unit_cost_estimate.attributes
    assert_redirected_to component_unit_cost_estimate_path(@component, assigns(:unit_cost_estimate))
  end
  
  test "should update xhr unit cost estimate" do
    xhr :put, :update, :component_id => @component, :id => @unit_cost_estimate.to_param, :unit_cost_estimate => @unit_cost_estimate.attributes
    assert_response(:success)
    assert_template(:update) 
  end

  test "should destroy unit_cost_estimate" do
    assert_difference('UnitCostEstimate.count', -1) do
      delete :destroy, :component_id => @component, :id => @unit_cost_estimate.to_param
    end

    assert_redirected_to project_component_path(@project, @component)
  end
end
