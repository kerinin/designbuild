require File.dirname(__FILE__) + '/../test_helper'

class DeadlinesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @deadline = Factory :deadline, :project => @project
    @task = Factory :task, :project => @project
    sign_in Factory :user
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

  test "should xhr get new" do
    xhr :get, :new, :project_id => @project.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should get new from task" do
    get :new, :task_id => @task.to_param
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

  test "should xhr create deadline" do
    assert_difference('Deadline.count') do
      xhr :post, :create, :project_id => @project.to_param, :deadline => {
        :name => 'blah', :date => '1/1/2000'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr deadline" do
    assert_no_difference('Deadline.count') do
      xhr :post, :create, :project_id => @project.to_param, :deadline => {
        :name => nil, :date => '1/1/2000'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should create deadline from task" do
    assert_difference('Deadline.count') do
      post :create, :task_id => @task.to_param, :deadline => {
        :name => 'blah', :date => '1/1/2000'
      }
    end

    assert_contains assigns(:deadline).tasks, @task
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

  test "should xhr get edit" do
    xhr :get, :edit, :project_id => @project.to_param, :id => @deadline.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should update deadline" do
    put :update, :project_id => @project.to_param, :id => @deadline.to_param, :deadline => @deadline.attributes
    assert_redirected_to project_deadline_path(@project, assigns(:deadline))
  end

  test "should xhr update deadline" do
    xhr :put, :update, :project_id => @project.to_param, :id => @deadline.to_param, :deadline => @deadline.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update deadline" do
    xhr :put, :update, :project_id => @project.to_param, :id => @deadline.to_param, :deadline => {
        :name => nil, :date => '1/1/2000'
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should destroy deadline" do
    assert_difference('Deadline.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @deadline.to_param
    end

    assert_redirected_to project_deadlines_path(@project)
  end
end
