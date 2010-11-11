require 'test_helper'

class ComponentsControllerTest < ActionController::TestCase
  setup do
    @component = components(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:components)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create component" do
    assert_difference('Component.count') do
      post :create, :component => @component.attributes
    end

    assert_redirected_to component_path(assigns(:component))
  end

  test "should show component" do
    get :show, :id => @component.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @component.to_param
    assert_response :success
  end

  test "should update component" do
    put :update, :id => @component.to_param, :component => @component.attributes
    assert_redirected_to component_path(assigns(:component))
  end

  test "should destroy component" do
    assert_difference('Component.count', -1) do
      delete :destroy, :id => @component.to_param
    end

    assert_redirected_to components_path
  end
end
