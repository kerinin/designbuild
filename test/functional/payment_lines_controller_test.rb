require 'test_helper'

class PaymentLinesControllerTest < ActionController::TestCase
  setup do
    @payment_line = payment_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payment_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payment_line" do
    assert_difference('PaymentLine.count') do
      post :create, :payment_line => @payment_line.attributes
    end

    assert_redirected_to payment_line_path(assigns(:payment_line))
  end

  test "should show payment_line" do
    get :show, :id => @payment_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @payment_line.to_param
    assert_response :success
  end

  test "should update payment_line" do
    put :update, :id => @payment_line.to_param, :payment_line => @payment_line.attributes
    assert_redirected_to payment_line_path(assigns(:payment_line))
  end

  test "should destroy payment_line" do
    assert_difference('PaymentLine.count', -1) do
      delete :destroy, :id => @payment_line.to_param
    end

    assert_redirected_to payment_lines_path
  end
end
