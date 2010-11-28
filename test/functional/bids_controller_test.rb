require File.dirname(__FILE__) + '/../test_helper'

class BidsControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @contract = Factory :contract, :project => @project
    @bid = Factory :bid, :contract => @contract
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :contract_id => @contract.to_param
    assert_response :success
    assert_not_nil assigns(:bids)
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
  
  test "should create bid" do
    assert_difference('Bid.count') do
      post :create, :contract_id => @contract.to_param, :bid => {
        :date => '1/1/1999', :raw_cost => 100, :contractor => 'billy bob'
      }
    end

    assert_redirected_to contract_bid_path(@contract, assigns(:bid))
  end

  test "should xhr create bid" do
    assert_difference('Bid.count') do
      xhr :post, :create, :contract_id => @contract.to_param, :bid => {
        :date => '1/1/1999', :raw_cost => 100, :contractor => 'billy bob'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr bid" do
    assert_no_difference('Bid.count') do
      xhr :post, :create, :contract_id => @contract.to_param, :bid => {
        :date => '1/1/1999', :raw_cost => nil, :contractor => 'billy bob'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show bid" do
    get :show, :contract_id => @contract.to_param, :id => @bid.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :contract_id => @contract.to_param, :id => @bid.to_param
    assert_response :success
  end

  test "should xhr get edit" do
    xhr :get, :edit, :contract_id => @contract.to_param, :id => @bid.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should update bid" do
    put :update, :contract_id => @contract.to_param, :id => @bid.to_param, :bid => @bid.attributes
    assert_redirected_to contract_bid_path(@contract, assigns(:bid))
  end

  test "should xhr update bid" do
    xhr :put, :update, :contract_id => @contract.to_param, :id => @bid.to_param, :bid => @bid.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update bid" do
    xhr :put, :update, :contract_id => @contract.to_param, :id => @bid.to_param, :bid => {
        :date => '1/1/1999', :raw_cost => nil, :contractor => 'billy bob'
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
    
  test "should destroy bid" do
    assert_difference('Bid.count', -1) do
      delete :destroy, :contract_id => @contract.to_param, :id => @bid.to_param
    end

    assert_redirected_to contract_bids_path(@contract)
  end
end
