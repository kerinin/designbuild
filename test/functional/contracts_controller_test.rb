require File.dirname(__FILE__) + '/../test_helper'

class ContractsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @contract = Factory :contract, :project => @project
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

  test "should create contract" do
    assert_difference('Contract.count') do
      post :create, :project_id => @project.to_param, :contract => {
        :contractor => 'bob', :bid => 100
      }
    end

    assert_redirected_to project_contract_path(@project, assigns(:contract))
  end

  test "should show contract" do
    get :show, :project_id => @project.to_param, :id => @contract.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @contract.to_param
    assert_response :success
  end

  test "should update contract" do
    put :update, :project_id => @project.to_param, :id => @contract.to_param, :contract => @contract.attributes
    assert_redirected_to project_contract_path(@project, assigns(:contract))
  end

  test "should destroy contract" do
    assert_difference('Contract.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @contract.to_param
    end

    assert_redirected_to project_contracts_path(@project)
  end
end
