require File.dirname(__FILE__) + '/../test_helper'

class DeadlinesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @deadline = Factory :deadline, :project => @project
  end

  test "should get index" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:deadlines)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param
    assert_response :success
  end

  test "should create deadline" do
    assert_difference('Deadline.count') do
      post :create, :project_id => @project.to_param, :deadline => {
        :name => 'blah', :date => '1/1/2000'
      }
    end

    assert_redirected_to project_deadline_path(@project, assigns(:deadline))
  end

  test "should show deadline" do
    get :show, :project_id => @project.to_param, :id => @deadline.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @deadline.to_param
    assert_response :success
  end

  test "should update deadline" do
    put :update, :project_id => @project.to_param, :id => @deadline.to_param, :deadline => @deadline.attributes
    assert_redirected_to project_deadline_path(@project, assigns(:deadline))
  end

  test "should destroy deadline" do
    assert_difference('Deadline.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @deadline.to_param
    end

    assert_redirected_to project_deadlines_path(@project)
  end
end
