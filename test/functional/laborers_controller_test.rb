require 'test_helper'

class LaborersControllerTest < ActionController::TestCase
  setup do
    @laborer = laborers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:laborers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create laborer" do
    assert_difference('Laborer.count') do
      post :create, :laborer => @laborer.attributes
    end

    assert_redirected_to laborer_path(assigns(:laborer))
  end

  test "should show laborer" do
    get :show, :id => @laborer.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @laborer.to_param
    assert_response :success
  end

  test "should update laborer" do
    put :update, :id => @laborer.to_param, :laborer => @laborer.attributes
    assert_redirected_to laborer_path(assigns(:laborer))
  end

  test "should destroy laborer" do
    assert_difference('Laborer.count', -1) do
      delete :destroy, :id => @laborer.to_param
    end

    assert_redirected_to laborers_path
  end
end
