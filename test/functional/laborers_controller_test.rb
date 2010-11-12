require File.dirname(__FILE__) + '/../test_helper'

class LaborersControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @laborer = Factory :laborer, :project => @project
  end

  test "should get index" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:laborers)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param
    assert_response :success
  end

  test "should create laborer" do
    assert_difference('Laborer.count') do
      post :create, :project_id => @project.to_param, :laborer => @laborer.attributes
    end

    assert_redirected_to project_laborer_path(@project, assigns(:laborer))
  end

  test "should show laborer" do
    get :show, :project_id => @project.to_param, :id => @laborer.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @laborer.to_param
    assert_response :success
  end

  test "should update laborer" do
    put :update, :project_id => @project.to_param, :id => @laborer.to_param, :laborer => @laborer.attributes
    assert_redirected_to project_laborer_path(@project, assigns(:laborer))
  end

  test "should destroy laborer" do
    assert_difference('Laborer.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @laborer.to_param
    end

    assert_redirected_to project_laborers_path(@project)
  end
end
