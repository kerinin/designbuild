require File.dirname(__FILE__) + '/../test_helper'

class ProjectsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    sign_in Factory :user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:projects)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should xhr get new" do
    xhr :get, :new
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should create project" do
    assert_difference('Project.count') do
      post :create, :project => {
        :name => 'blah'
      }
    end

    assert_redirected_to project_path(assigns(:project))
  end

  test "should xhr create project" do
    assert_difference('Project.count') do
      xhr :post, :create, :project => {
        :name => 'blah'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr project" do
    assert_no_difference('Project.count') do
      xhr :post, :create, :project => {
        :name => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show project" do
    get :show, :id => @project.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @project.to_param
    assert_response :success
  end

  test "should xhr get edit" do
    xhr :get, :edit, :id => @project.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should update project" do
    put :update, :id => @project.to_param, :project => @project.attributes
    assert_redirected_to project_path(assigns(:project))
  end

  test "should xhr update project" do
    xhr :put, :update, :id => @project.to_param, :project => @project.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update project" do
    xhr :put, :update, :id => @project.to_param, :project => {
        :name => nil
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should destroy project" do
    assert_difference('Project.count', -1) do
      delete :destroy, :id => @project.to_param
    end

    assert_redirected_to projects_path
  end
end
