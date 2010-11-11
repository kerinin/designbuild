require 'test_helper'

class RelativeDeadlinesControllerTest < ActionController::TestCase
  setup do
    @relative_deadline = relative_deadlines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:relative_deadlines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create relative_deadline" do
    assert_difference('RelativeDeadline.count') do
      post :create, :relative_deadline => @relative_deadline.attributes
    end

    assert_redirected_to relative_deadline_path(assigns(:relative_deadline))
  end

  test "should show relative_deadline" do
    get :show, :id => @relative_deadline.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @relative_deadline.to_param
    assert_response :success
  end

  test "should update relative_deadline" do
    put :update, :id => @relative_deadline.to_param, :relative_deadline => @relative_deadline.attributes
    assert_redirected_to relative_deadline_path(assigns(:relative_deadline))
  end

  test "should destroy relative_deadline" do
    assert_difference('RelativeDeadline.count', -1) do
      delete :destroy, :id => @relative_deadline.to_param
    end

    assert_redirected_to relative_deadlines_path
  end
end
