require File.dirname(__FILE__) + '/../test_helper'

class ComponentsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    sign_in Factory :user
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
  
  test "should xhr get new" do
    xhr :get, :new, :project_id => @project.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end

  test "should create component" do
    assert_difference('Component.count') do
      post :create, :project_id => @project.to_param, :component => {
        :name => 'blah'
      }
    end

    assert_redirected_to project_component_path(@project, assigns(:component))
  end

  test "should xhr create component" do
    assert_difference('Component.count') do
      xhr :post, :create, :project_id => @project.to_param, :component => {
        :name => 'blah'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr component" do
    assert_no_difference('Component.count') do
      xhr :post, :create, :project_id => @project.to_param, :component => {
        :name => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show component" do
    get :show, :project_id => @project.to_param, :id => @component.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @component.to_param
    assert_response :success
  end
  
  test "should xhr get edit" do
    xhr :get, :edit, :project_id => @project.to_param, :id => @component.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end

  test "should update component" do
    put :update, :project_id => @project.to_param, :id => @component.to_param, :component => @component.attributes
    assert_redirected_to project_component_path(@project, assigns(:component))
  end

  test "should xhr update component" do
    xhr :put, :update, :project_id => @project.to_param, :id => @component.to_param, :component => @component.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update component" do
    xhr :put, :update, :project_id => @project.to_param, :id => @component.to_param, :component => {
        :name => nil
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should destroy component" do
    assert_difference('Component.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @component.to_param
    end

    assert_redirected_to project_components_path(@project)
  end
end
