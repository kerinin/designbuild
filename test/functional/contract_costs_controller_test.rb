require File.dirname(__FILE__) + '/../test_helper'

class ContractCostsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @contract = Factory :contract, :project => @project
    @contract_cost = Factory :contract_cost, :contract => @contract
    sign_in Factory :user
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
  
  test "should xhr get new" do
    xhr :get, :new, :contract_id => @contract.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end

  test "should create contract_cost" do
    assert_difference('ContractCost.count') do
      post :create, :contract_id => @contract.to_param, :contract_cost => {
        :date => '1/1/2000', :raw_cost => '100'
      }
    end

    assert_redirected_to contract_contract_cost_path(@contract, assigns(:contract_cost))
  end

  test "should xhr create contract cost" do
    assert_difference('ContractCost.count') do
      xhr :post, :create, :contract_id => @contract.to_param, :contract_cost => {
        :date => '1/1/2000', :raw_cost => '100'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr contract cost" do
    assert_no_difference('ContractCost.count') do
      xhr :post, :create, :contract_id => @contract.to_param, :contract_cost => {
        :date => '1/1/2000', :raw_cost => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show contract_cost" do
    get :show, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    assert_response :success
  end

  test "should xhr get edit" do
    xhr :get, :edit, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should update contract_cost" do
    put :update, :contract_id => @contract.to_param, :id => @contract_cost.to_param, :contract_cost => @contract_cost.attributes
    assert_redirected_to contract_contract_cost_path(@contract, assigns(:contract_cost))
  end

  test "should xhr update contract cost" do
    xhr :put, :update, :contract_id => @contract.to_param, :id => @contract_cost.to_param, :contract_cost => @contract_cost.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update contract cost" do
    xhr :put, :update, :contract_id => @contract.to_param, :id => @contract_cost.to_param, :contract_cost => {
        :date => '1/1/2000', :raw_cost => nil
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should destroy contract_cost" do
    assert_difference('ContractCost.count', -1) do
      delete :destroy, :contract_id => @contract.to_param, :id => @contract_cost.to_param
    end

    assert_redirected_to project_contract_path(@project, @contract)
  end
end
