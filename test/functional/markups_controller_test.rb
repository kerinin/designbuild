require File.dirname(__FILE__) + '/../test_helper'

class MarkupsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @markup = Factory :markup, :parent => @project
  end

  test "should get index" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:markups)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param
    assert_response :success
  end

  test "should create markup" do
    assert_difference('Markup.count') do
      post :create, :project_id => @project.to_param, :markup => @markup.attributes
    end

    assert_redirected_to project_markup_path(@project, assigns(:markup))
  end

  test "should show markup" do
    get :show, :project_id => @project.to_param, :id => @markup.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @markup.to_param
    assert_response :success
  end

  test "should update markup" do
    put :update, :project_id => @project.to_param, :id => @markup.to_param, :markup => @markup.attributes
    assert_redirected_to project_markup_path(@project, assigns(:markup))
  end

  test "should destroy markup" do
    assert_difference('Markup.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @markup.to_param
    end

    assert_redirected_to project_path(@project)
  end
end
