require File.dirname(__FILE__) + '/../test_helper'

class RelativeDeadlinesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @deadline = Factory :deadline, :project => @project
    @relative_deadline = Factory :relative_deadline, :parent_deadline => @deadline
  end

  test "should get index" do
    get :index, :deadline_id => @deadline.to_param
    assert_response :success
    assert_not_nil assigns(:relative_deadlines)
  end

  test "should get new" do
    get :new, :deadline_id => @deadline.to_param
    assert_response :success
  end

  test "should create relative_deadline" do
    assert_difference('RelativeDeadline.count') do
      post :create, :deadline_id => @deadline.to_param, :relative_deadline => {
        :name => 'blah', :interval => 30
      }
    end

    assert_redirected_to deadline_relative_deadline_path(@deadline, assigns(:relative_deadline))
  end

  test "should show relative_deadline" do
    get :show, :deadline_id => @deadline.to_param, :id => @relative_deadline.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :deadline_id => @deadline.to_param, :id => @relative_deadline.to_param
    assert_response :success
  end

  test "should update relative_deadline" do
    put :update, :deadline_id => @deadline.to_param, :id => @relative_deadline.to_param, :relative_deadline => @relative_deadline.attributes
    assert_redirected_to deadline_relative_deadline_path(@deadline, assigns(:relative_deadline))
  end

  test "should destroy relative_deadline" do
    assert_difference('RelativeDeadline.count', -1) do
      delete :destroy, :deadline_id => @deadline.to_param, :id => @relative_deadline.to_param
    end

    assert_redirected_to deadline_relative_deadlines_path(@deadline)
  end
end
