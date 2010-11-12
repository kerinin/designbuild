require File.dirname(__FILE__) + '/../test_helper'

class DerivedQuantitiesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @quantity = Factory :quantity, :component => @component
    @derived_quantity = Factory :derived_quantity, :parent_quantity => @quantity
  end

  test "should get index" do
    get :index, :project_id => @project.to_param, :component_id => @component.to_param
    assert_response :success
    assert_not_nil assigns(:derived_quantities)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param, :component_id => @component.to_param
    assert_response :success
  end

  test "should create derived_quantity" do
    assert_difference('DerivedQuantity.count') do
      post :create, :project_id => @project.to_param, :component_id => @component.to_param, :derived_quantity => @derived_quantity.attributes
    end

    assert_redirected_to project_component_derived_quantity_path(@project, @component, assigns(:derived_quantity))
  end

  test "should show derived_quantity" do
    get :show, :project_id => @project.to_param, :component_id => @component.to_param, :id => @derived_quantity.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :component_id => @component.to_param, :id => @derived_quantity.to_param
    assert_response :success
  end

  test "should update derived_quantity" do
    put :update, :project_id => @project.to_param, :component_id => @component.to_param, :id => @derived_quantity.to_param, :derived_quantity => @derived_quantity.attributes
    assert_redirected_to project_component_derived_quantity_path(@project, @component, assigns(:derived_quantity))
  end

  test "should destroy derived_quantity" do
    assert_difference('DerivedQuantity.count', -1) do
      delete :destroy, :project_id => @project.to_param, :component_id => @component.to_param, :id => @derived_quantity.to_param
    end

    assert_redirected_to project_component_derived_quantities_path( @project, @component)
  end
end
