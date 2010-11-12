require File.dirname(__FILE__) + '/../test_helper'

class QuantitiesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @quantity = Factory :quantity, :component => @component
  end

  test "should get index" do
    get :index, :project_id => @project.to_param, :component_id => @component.to_param
    assert_response :success
    assert_not_nil assigns(:quantities)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param, :component_id => @component.to_param
    assert_response :success
  end

  test "should create quantity" do
    assert_difference('Quantity.count') do
      post :create, :project_id => @project.to_param, :component_id => @component.to_param, :quantity => @quantity.attributes
    end

    assert_redirected_to project_component_quantity_path(@project, @component, assigns(:quantity))
  end

  test "should show quantity" do
    get :show, :project_id => @project.to_param, :component_id => @component.to_param, :id => @quantity.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :component_id => @component.to_param, :id => @quantity.to_param
    assert_response :success
  end

  test "should update quantity" do
    put :update, :project_id => @project.to_param, :component_id => @component.to_param, :id => @quantity.to_param, :quantity => @quantity.attributes
    assert_redirected_to project_component_quantity_path(@project, @component, assigns(:quantity))
  end

  test "should destroy quantity" do
    assert_difference('Quantity.count', -1) do
      delete :destroy, :project_id => @project.to_param, :component_id => @component.to_param, :id => @quantity.to_param
    end

    assert_redirected_to project_component_quantities_path(@project, @component)
  end
end
