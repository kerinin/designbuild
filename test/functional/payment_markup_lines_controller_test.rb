require 'test_helper'

class PaymentMarkupLinesControllerTest < ActionController::TestCase
  setup do
    @payment_markup_line = payment_markup_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:payment_markup_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create payment_markup_line" do
    assert_difference('PaymentMarkupLine.count') do
      post :create, :payment_markup_line => @payment_markup_line.attributes
    end

    assert_redirected_to payment_markup_line_path(assigns(:payment_markup_line))
  end

  test "should show payment_markup_line" do
    get :show, :id => @payment_markup_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @payment_markup_line.to_param
    assert_response :success
  end

  test "should update payment_markup_line" do
    put :update, :id => @payment_markup_line.to_param, :payment_markup_line => @payment_markup_line.attributes
    assert_redirected_to payment_markup_line_path(assigns(:payment_markup_line))
  end

  test "should destroy payment_markup_line" do
    assert_difference('PaymentMarkupLine.count', -1) do
      delete :destroy, :id => @payment_markup_line.to_param
    end

    assert_redirected_to payment_markup_lines_path
  end
end
