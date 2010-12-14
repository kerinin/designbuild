require File.dirname(__FILE__) + '/../test_helper'

class PaymentLinesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @contract = Factory :contract, :project => @project
    @payment = Factory :payment, :project => @project
    
    @payment_line = Factory :payment_line, :payment => @payment, :cost => @contract
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :payment_id => @payment.to_param
    assert_response :success
    assert_not_nil assigns(:payment_lines)
  end

  test "should get new" do
    get :new, :payment_id => @payment.to_param
    assert_response :success
  end

  test "should create payment_line" do
    assert_difference('PaymentLine.count') do
      post :create, :payment_id => @payment.to_param, :payment_line => @payment_line.attributes
    end

    assert_redirected_to payment_line_items_path(@payment, assigns(:payment_line))
  end

  test "should show payment_line" do
    get :show, :payment_id => @payment.to_param, :id => @payment_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :payment_id => @payment.to_param, :id => @payment_line.to_param
    assert_response :success
  end

  test "should update payment_line" do
    put :update, :payment_id => @payment.to_param, :id => @payment_line.to_param, :payment_line => @payment_line.attributes
    assert_redirected_to payment_line_items_path(@payment, assigns(:payment_line))
  end

  test "should destroy payment_line" do
    assert_difference('PaymentLine.count', -1) do
      delete :destroy, :payment_id => @payment.to_param, :id => @payment_line.to_param
    end

    assert_redirected_to payment_path(@payment)
  end
end
