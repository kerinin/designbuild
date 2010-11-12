require File.dirname(__FILE__) + '/../test_helper'

class BidsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @contract = Factory :contract, :project => @project
    @bid = Factory :bid, :contract => @contract
  end

  test "should get index" do
    get :index, :project_id => @project.to_param, :contract_id => @contract.to_param
    assert_response :success
    assert_not_nil assigns(:bids)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param, :contract_id => @contract.to_param
    assert_response :success
  end

  test "should create bid" do
    assert_difference('Bid.count') do
      post :create, :project_id => @project.to_param, :contract_id => @contract.to_param, :bid => @bid.attributes
    end

    assert_redirected_to project_contract_bid_path(@project, @contract, assigns(:bid))
  end

  test "should show bid" do
    get :show, :project_id => @project.to_param, :contract_id => @contract.to_param, :id => @bid.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :contract_id => @contract.to_param, :id => @bid.to_param
    assert_response :success
  end

  test "should update bid" do
    put :update, :project_id => @project.to_param, :contract_id => @contract.to_param, :id => @bid.to_param, :bid => @bid.attributes
    assert_redirected_to project_contract_bid_path(@project, @contract, assigns(:bid))
  end

  test "should destroy bid" do
    assert_difference('Bid.count', -1) do
      delete :destroy, :project_id => @project.to_param, :contract_id => @contract.to_param, :id => @bid.to_param
    end

    assert_redirected_to project_contract_bids_path(@project, @contract)
  end
end
