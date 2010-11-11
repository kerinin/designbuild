require 'test_helper'

class ContractCostsControllerTest < ActionController::TestCase
  setup do
    @contract_cost = contract_costs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contract_costs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contract_cost" do
    assert_difference('ContractCost.count') do
      post :create, :contract_cost => @contract_cost.attributes
    end

    assert_redirected_to contract_cost_path(assigns(:contract_cost))
  end

  test "should show contract_cost" do
    get :show, :id => @contract_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @contract_cost.to_param
    assert_response :success
  end

  test "should update contract_cost" do
    put :update, :id => @contract_cost.to_param, :contract_cost => @contract_cost.attributes
    assert_redirected_to contract_cost_path(assigns(:contract_cost))
  end

  test "should destroy contract_cost" do
    assert_difference('ContractCost.count', -1) do
      delete :destroy, :id => @contract_cost.to_param
    end

    assert_redirected_to contract_costs_path
  end
end
