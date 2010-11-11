require 'test_helper'

class DerivedQuantitiesControllerTest < ActionController::TestCase
  setup do
    @derived_quantity = derived_quantities(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:derived_quantities)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create derived_quantity" do
    assert_difference('DerivedQuantity.count') do
      post :create, :derived_quantity => @derived_quantity.attributes
    end

    assert_redirected_to derived_quantity_path(assigns(:derived_quantity))
  end

  test "should show derived_quantity" do
    get :show, :id => @derived_quantity.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @derived_quantity.to_param
    assert_response :success
  end

  test "should update derived_quantity" do
    put :update, :id => @derived_quantity.to_param, :derived_quantity => @derived_quantity.attributes
    assert_redirected_to derived_quantity_path(assigns(:derived_quantity))
  end

  test "should destroy derived_quantity" do
    assert_difference('DerivedQuantity.count', -1) do
      delete :destroy, :id => @derived_quantity.to_param
    end

    assert_redirected_to derived_quantities_path
  end
end
