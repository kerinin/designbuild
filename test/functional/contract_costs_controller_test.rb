require File.dirname(__FILE__) + '/../test_helper'

class ContractCostsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @contract = Factory :contract, :project => @project
    @contract_cost = Factory :contract_cost, :contract => @contract
  end

  test "should get index" do
    get :index, :contract_id => @contract.to_param
    assert_response :success
    assert_not_nil assigns(:contract_costs)
  end

  test "should get new" do
    get :new, :contract_id => @contract.to_param
    assert_response :success
  end

  test "should create contract_cost" do
    assert_difference('ContractCost.count') do
      post :create, :contract_id => @contract.to_param, :contract_cost => {
        :date => '1/1/2000', :cost => '100'
      }
    end

    assert_redirected_to contract_cost_path(@contract, assigns(:contract_cost))
  end

  test "should show contract_cost" do
    get :show, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    assert_response :success
  end

  test "should update contract_cost" do
    put :update, :contract_id => @contract.to_param, :id => @contract_cost.to_param, :contract_cost => @contract_cost.attributes
    assert_redirected_to contract_cost_path(@contract, assigns(:contract_cost))
  end

  test "should destroy contract_cost" do
    assert_difference('ContractCost.count', -1) do
      delete :destroy, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    end

    assert_redirected_to contract_costs_path(@contract)
  end
end
