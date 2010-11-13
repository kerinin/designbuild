require File.dirname(__FILE__) + '/../test_helper'

class QuantitiesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @quantity = Factory :quantity, :component => @component
  end

  test "should get index" do
    get :index, :component_id => @component.to_param
    assert_response :success
    assert_not_nil assigns(:quantities)
  end

  test "should get new" do
    get :new, :component_id => @component.to_param
    assert_response :success
  end

  test "should create quantity" do
    assert_difference('Quantity.count') do
      post :create, :component_id => @component.to_param, :quantity => {
        :name => 'blah', :value => 10, :unit => 'ft', :drop => 0.1
      }
    end

    assert_redirected_to component_quantity_path(@component, assigns(:quantity))
  end

  test "should show quantity" do
    get :show, :component_id => @component.to_param, :id => @quantity.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :component_id => @component.to_param, :id => @quantity.to_param
    assert_response :success
  end

  test "should update quantity" do
    put :update, :component_id => @component.to_param, :id => @quantity.to_param, :quantity => @quantity.attributes
    assert_redirected_to component_quantity_path(@component, assigns(:quantity))
  end

  test "should destroy quantity" do
    assert_difference('Quantity.count', -1) do
      delete :destroy, :component_id => @component.to_param, :id => @quantity.to_param
    end

    assert_redirected_to component_quantities_path(@component)
  end
end
