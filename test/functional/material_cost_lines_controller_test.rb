require 'test_helper'

class MaterialCostLinesControllerTest < ActionController::TestCase
  setup do
    @material_cost_line = material_cost_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:material_cost_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create material_cost_line" do
    assert_difference('MaterialCostLine.count') do
      post :create, :material_cost_line => @material_cost_line.attributes
    end

    assert_redirected_to material_cost_line_path(assigns(:material_cost_line))
  end

  test "should show material_cost_line" do
    get :show, :id => @material_cost_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @material_cost_line.to_param
    assert_response :success
  end

  test "should update material_cost_line" do
    put :update, :id => @material_cost_line.to_param, :material_cost_line => @material_cost_line.attributes
    assert_redirected_to material_cost_line_path(assigns(:material_cost_line))
  end

  test "should destroy material_cost_line" do
    assert_difference('MaterialCostLine.count', -1) do
      delete :destroy, :id => @material_cost_line.to_param
    end

    assert_redirected_to material_cost_lines_path
  end
end
