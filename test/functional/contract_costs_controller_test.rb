require File.dirname(__FILE__) + '/../test_helper'

class ContractCostsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @contract = Factory :contract, :project => @project
    @contract_cost = Factory :contract_cost, :contract => @contract
  end

  test "should get index" do
    get :index, :project_id => @project.to_param, :contract_id => @contract.to_param
    assert_response :success
    assert_not_nil assigns(:contract_costs)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param, :contract_id => @contract.to_param
    assert_response :success
  end

  test "should create contract_cost" do
    assert_difference('ContractCost.count') do
      post :create, :project_id => @project.to_param, :contract_id => @contract.to_param, :contract_cost => @contract_cost.attributes
    end

    assert_redirected_to project_contract_contract_cost_path(@project, @contract, assigns(:contract_cost))
  end

  test "should show contract_cost" do
    get :show, :project_id => @project.to_param, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    assert_response :success
  end

  test "should update contract_cost" do
    put :update, :project_id => @project.to_param, :contract_id => @contract.to_param, :id => @contract_cost.to_param, :contract_cost => @contract_cost.attributes
    assert_redirected_to project_contract_contract_cost_path(@project, @contract, assigns(:contract_cost))
  end

  test "should destroy contract_cost" do
    assert_difference('ContractCost.count', -1) do
      delete :destroy, :project_id => @project.to_param, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    end

    assert_redirected_to project_contract_contract_costs_path(@project, @contract)
  end
end
