require File.dirname(__FILE__) + '/../test_helper'

class TasksControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @task = Factory :task, :project => @project
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:tasks)
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
  
  test "should create task" do
    assert_difference('Task.count') do
      post :create, :project_id => @project.to_param, :task => {
        :name => 'blah'
      }
    end

    assert_redirected_to project_task_path(@project, assigns(:task))
  end

  test "should xhr create task" do
    assert_difference('Task.count') do
      xhr :post, :create, :project_id => @project.to_param, :task => {
        :name => 'blah'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr task" do
    assert_no_difference('Task.count') do
      xhr :post, :create, :project_id => @project.to_param, :task => {
        :name => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show task" do
    get :show, :project_id => @project.to_param, :id => @task.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @task.to_param
    assert_response :success
  end

  test "should xhr get edit" do
    xhr :get, :edit, :project_id => @project.to_param, :id => @task.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should update task" do
    put :update, :project_id => @project.to_param, :id => @task.to_param, :task => @task.attributes
    assert_redirected_to project_task_path(@project, assigns(:task))
  end

  test "should xhr update task" do
    xhr :put, :update, :project_id => @project.to_param, :id => @task.to_param, :task => @task.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update task" do
    xhr :put, :update, :project_id => @project.to_param, :id => @task.to_param, :task => {
        :name => nil
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should destroy task" do
    assert_difference('Task.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @task.to_param
    end

    assert_redirected_to project_tasks_path(@project)
  end
end
