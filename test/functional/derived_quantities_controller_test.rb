require File.dirname(__FILE__) + '/../test_helper'

class DerivedQuantitiesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @quantity = Factory :quantity, :component => @component
    @derived_quantity = Factory :derived_quantity, :parent_quantity => @quantity
  end

  test "should get index" do
    get :index, :component_id => @component.to_param
    assert_response :success
    assert_not_nil assigns(:derived_quantities)
  end

  test "should get new" do
    get :new, :component_id => @component.to_param
    assert_response :success
  end

  test "should create derived_quantity" do
    assert_difference('DerivedQuantity.count') do
      post :create, :component_id => @component.to_param, :derived_quantity => {
        :parent_quantity_id => @quantity.id, :name => 'blah', :multiplier => '1'
      }
    end

    assert_redirected_to component_derived_quantity_path(@component, assigns(:derived_quantity))
  end

  test "should show derived_quantity" do
    get :show, :component_id => @component.to_param, :id => @derived_quantity.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :component_id => @component.to_param, :id => @derived_quantity.to_param
    assert_response :success
  end

  test "should update derived_quantity" do
    put :update, :component_id => @component.to_param, :id => @derived_quantity.to_param, :derived_quantity => @derived_quantity.attributes
    assert_redirected_to component_derived_quantity_path(@component, assigns(:derived_quantity))
  end

  test "should destroy derived_quantity" do
    assert_difference('DerivedQuantity.count', -1) do
      delete :destroy, :component_id => @component.to_param, :id => @derived_quantity.to_param
    end

    assert_redirected_to component_derived_quantities_path( @component)
  end
end
