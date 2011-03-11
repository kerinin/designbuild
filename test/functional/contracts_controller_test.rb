require File.dirname(__FILE__) + '/../test_helper'

class ContractsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @contract = Factory :contract, :project => @project, :component => @component
    #@c_contract = Factory :contract, :project => @project, :component => @component
    
    @project.reload
    
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:contracts)
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

  test "should xhr get new from component" do
    xhr :get, :new, :component_id => @component.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
    assert_equal @component, assigns[:contract].component
  end
    
  test "should create contract" do
    assert_difference('Contract.count') do
      post :create, :component_id => @component.to_param, :contract => {
        :name => 'bob'
      }
    end

    assert_redirected_to project_contract_path(@project, assigns(:contract))
  end

  test "should xhr create contract" do
    assert_difference('Contract.count') do
      xhr :post, :create, :component_id => @project.to_param, :contract => {
        :name => 'bob'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr contract" do
    assert_no_difference('Contract.count') do
      xhr :post, :create, :component_id => @project.to_param, :contract => {
        :name => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end

  test "should xhr create contract from component" do
    assert_difference('Contract.count') do
      xhr :post, :create, :component_id => @component.to_param, :contract => {
        :name => 'bob'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
    assert_equal @component, assigns[:contract].component
  end
  
  test "should fail to create xhr contract from component" do
    assert_no_difference('Contract.count') do
      xhr :post, :create, :component_id => @component.to_param, :contract => {
        :name => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
    assert_equal @component, assigns[:contract].component
  end
    
  test "should show contract" do
    get :show, :project_id => @project.to_param, :id => @contract.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @contract.to_param
    assert_response :success
  end

  test "should xhr get edit" do
    xhr :get, :edit, :project_id => @project.to_param, :id => @contract.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end

  test "should xhr get edit from component" do
    xhr :get, :edit, :component_id => @component.to_param, :id => @contract.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
    
  test "should update contract" do
    put :update, :project_id => @project.to_param, :id => @contract.to_param, :contract => @contract.attributes
    assert_redirected_to project_contract_path(@project, assigns(:contract))
  end

  test "should xhr update contract" do
    xhr :put, :update, :project_id => @project.to_param, :id => @contract.to_param, :contract => @contract.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update contract" do
    xhr :put, :update, :project_id => @project.to_param, :id => @contract.to_param, :contract => {
        :name => nil
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end

  test "should xhr update contract from component" do
    xhr :put, :update, :component_id => @component.to_param, :id => @contract.to_param, :contract => @contract.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update contract from component" do
    xhr :put, :update, :component_id => @component.to_param, :id => @contract.to_param, :contract => {
        :name => nil
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
    
  test "should destroy contract" do
    assert_difference('Contract.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @contract.to_param
    end

    assert_redirected_to component_path(@component)
  end
end
