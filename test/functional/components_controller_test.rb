require File.dirname(__FILE__) + '/../test_helper'

class ComponentsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
  end

  test "should get index" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:components)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param
    assert_response :success
  end

  test "should create component" do
    assert_difference('Component.count') do
      post :create, :project_id => @project.to_param, :component => {
        :name => 'blah'
      }
    end

    assert_redirected_to project_component_path(@project, assigns(:component))
  end

  test "should show component" do
    get :show, :project_id => @project.to_param, :id => @component.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @component.to_param
    assert_response :success
  end

  test "should update component" do
    put :update, :project_id => @project.to_param, :id => @component.to_param, :component => @component.attributes
    assert_redirected_to project_component_path(@project, assigns(:component))
  end

  test "should destroy component" do
    assert_difference('Component.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @component.to_param
    end

    assert_redirected_to project_components_path(@project)
  end
end
