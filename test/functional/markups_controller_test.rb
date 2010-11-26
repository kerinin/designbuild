require File.dirname(__FILE__) + '/../test_helper'

class MarkupsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @task = Factory :task, :project => @project
    @contract = Factory :contract, :project => @project
    
    @markup = Factory :markup
    sign_in Factory :user
  end
  
  teardown do
    Project.delete_all
    Component.delete_all
    Task.delete_all
    Contract.delete_all
    Markup.delete_all
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:markups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end
  
  test "should get new w/ associated project" do
    get :new, :project_id => @project.id
    assert_response :success
  end
  
  test "should get new w/ associated task" do
    get :new, :task_id => @task.id
    assert_response :success
  end
  
  test "should get new w/ associated contract" do
    get :new, :contract_id => @contract.id
    assert_response :success
  end
  
  test "should get new w/ associated component" do
    get :new, :component_id => @component.id
    assert_response :success
  end

  test "should create markup" do
    assert_difference('Markup.count') do
      post :create, :markup => @markup.attributes
    end

    assert_redirected_to markup_path(assigns(:markup))
  end
  
  test "should create markup w/ associated project" do
    assert_difference('Markup.count') do
      post :create, :markup => {
        :name => 'Test', 
        :percent => 20, 
        :markings_attributes => [ { :markupable_id => @project.id, :markupable_type => 'Project' } ]
      }
    end
    assert_contains assigns(:markup).projects, @project
  end
  
  test "should create markup w/ associated task" do
    assert_difference('Markup.count') do
      post :create, :markup => {
        :name => 'Test', 
        :percent => 20, 
        :markings_attributes => [ { :markupable_id => @task.id, :markupable_type => 'Task' } ]
      }
    end
    assert_contains assigns(:markup).tasks, @task
  end
  
  test "should create markup w/ associated component" do
    assert_difference('Markup.count') do
      post :create, :markup => {
        :name => 'Test', 
        :percent => 20, 
        :markings_attributes => [ { :markupable_id => @component.id, :markupable_type => 'Component' } ]
      }
    end
    assert_contains assigns(:markup).components, @component
  end
  
  test "should create markup w/ associated contract" do
    assert_difference('Markup.count') do
      post :create, :markup => {
        :name => 'Test', 
        :percent => 20, 
        :markings_attributes => [ { :markupable_id => @contract.id, :markupable_type => 'Contract' } ]
      }
    end
    assert_contains assigns(:markup).contracts, @contract
  end

  test "should show markup" do
    get :show, :id => @markup.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @markup.to_param
    assert_response :success
  end

  test "should update markup" do
    put :update, :id => @markup.to_param, :markup => @markup.attributes
    assert_redirected_to markup_path(assigns(:markup))
  end

  test "should destroy markup" do
    assert_difference('Markup.count', -1) do
      delete :destroy, :id => @markup.to_param
    end

    assert_redirected_to markups_path
  end
  
  test "should add to project" do
    get :add_to_project, :project_id => @project.to_param, :id => @markup.to_param
    assert_redirected_to project_path(@project)
    assert_contains assigns[:parent].markups, @markup
  end
  
  test "should remove from project" do
    get :remove_from_project, :project_id => @project.to_param, :id => @markup.to_param
    assert_redirected_to project_path(@project)
    assert_does_not_contain assigns[:parent].markups, @markup
  end
  
  test "should add to component" do
    get :add_to_component, :component_id => @component.to_param, :id => @markup.to_param
    assert_redirected_to project_component_path(@project, @component)
    assert_contains assigns[:parent].markups, @markup
  end
  
  test "should remove from component" do
    get :remove_from_component, :component_id => @component.to_param, :id => @markup.to_param
    assert_redirected_to project_component_path(@project, @component)
    assert_does_not_contain assigns[:parent].markups, @markup
  end
  
  test "should add to task" do
    get :add_to_task, :task_id => @task.to_param, :id => @markup.to_param
    assert_redirected_to project_task_path(@project, @task)
    assert_contains assigns[:parent].markups, @markup
  end
  
  test "should remove from task" do
    get :remove_from_task, :task_id => @task.to_param, :id => @markup.to_param
    assert_redirected_to project_task_path(@project, @task)
    assert_does_not_contain assigns[:parent].markups, @markup
  end
  
  test "should add to contract" do
    get :add_to_contract, :contract_id => @contract.to_param, :id => @markup.to_param
    assert_redirected_to project_contract_path(@project,@contract)
    assert_contains assigns[:parent].markups, @markup
  end
  
  test "should remove from contract" do
    get :remove_from_contract, :contract_id => @contract.to_param, :id => @markup.to_param
    assert_redirected_to project_contract_path(@project,@contract)
    assert_does_not_contain assigns[:parent].markups, @markup
  end
end
