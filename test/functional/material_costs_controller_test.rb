require 'test_helper'

class MaterialCostsControllerTest < ActionController::TestCase
  setup do
    @material_cost = material_costs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:material_costs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create material_cost" do
    assert_difference('MaterialCost.count') do
      post :create, :material_cost => @material_cost.attributes
    end

    assert_redirected_to material_cost_path(assigns(:material_cost))
  end

  test "should show material_cost" do
    get :show, :id => @material_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @material_cost.to_param
    assert_response :success
  end

  test "should update material_cost" do
    put :update, :id => @material_cost.to_param, :material_cost => @material_cost.attributes
    assert_redirected_to material_cost_path(assigns(:material_cost))
  end

  test "should destroy material_cost" do
    assert_difference('MaterialCost.count', -1) do
      delete :destroy, :id => @material_cost.to_param
    end

    assert_redirected_to material_costs_path
  end
end
