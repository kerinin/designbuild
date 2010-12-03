require File.dirname(__FILE__) + '/../test_helper'

class MarkupsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @markup = Factory :markup, :percent => 100
    @markup2 = Factory :markup, :percent => 100
    @markup3 = Factory :markup, :percent => 100
    
    @project.markups << @markup3
    @component = Factory :component, :project => @project
    @component.markups << [@markup, @markup2]
    @task = Factory :task, :project => @project
    @task.markups << [@markup, @markup2]
    @contract = Factory :contract, :project => @project
    @contract.markups << [@markup, @markup2]

    sign_in Factory :user
  end
  
  teardown do
    Project.delete_all
    Component.delete_all
    Task.delete_all
    Contract.delete_all
    Markup.delete_all
  end

  test "should remove markup from component" do
    assert_equal 300, @component.reload.total_markup
    
    get :remove_from_component, :component_id => @component.to_param, :id => @markup.to_param
    assert_redirected_to project_component_path(@project, @component)
    
    assert_does_not_contain @component.reload.markups, @markup
    assert_contains @component.reload.markups, @markup2
    assert_equal 200, @component.reload.total_markup
  end

  test "should remove markup from project" do
    get :remove_from_project, :project_id => @project.to_param, :id => @markup3.to_param
    assert_redirected_to project_path(@project)
    
    assert_does_not_contain @component.reload.markups, @markup3
    assert_equal 200, @component.reload.total_markup
    assert_equal 200, @task.reload.total_markup
    assert_equal 200, @contract.reload.total_markup
  end

  test "should remove markup from contract" do
    assert_equal 300, @contract.reload.total_markup
    
    get :remove_from_contract, :contract_id => @contract.to_param, :id => @markup.to_param
    assert_redirected_to project_contract_path(@project, @contract)
    
    assert_does_not_contain @contract.reload.markups, @markup
    assert_contains @contract.reload.markups, @markup2
    assert_equal 200, @contract.reload.total_markup
  end

  test "should remove markup from task" do
    assert_equal 300, @task.reload.total_markup
    
    get :remove_from_task, :task_id => @task.to_param, :id => @markup.to_param
    assert_redirected_to project_task_path(@project, @task)
    
    assert_does_not_contain @task.reload.markups, @markup
    assert_contains @task.reload.markups, @markup2
    assert_equal 200, @task.reload.total_markup
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

  test "should xhr get new" do
    xhr :get, :new
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
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

  test "should xhr create markup" do
    assert_difference('Markup.count') do
      xhr :post, :create, :markup => @markup.attributes
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr markup" do
    assert_no_difference('Markup.count') do
      xhr :post, :create, :markup => {
        :name => 'Test', 
        :percent => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show markup" do
    get :show, :id => @markup.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @markup.to_param
    assert_response :success
  end

  test "should xhr get edit" do
    xhr :get, :edit, :id => @markup.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should update markup" do
    put :update, :id => @markup.to_param, :markup => @markup.attributes
    assert_redirected_to markup_path(assigns(:markup))
  end

  test "should xhr update markup" do
    xhr :put, :update, :id => @markup.to_param, :markup => @markup.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update markup" do
    xhr :put, :update, :id => @markup.to_param, :markup => {
        :name => 'Test', 
        :percent => nil
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
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
