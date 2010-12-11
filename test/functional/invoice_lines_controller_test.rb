require 'test_helper'

class InvoiceLinesControllerTest < ActionController::TestCase
  setup do
    @invoice_line = invoice_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice_line" do
    assert_difference('InvoiceLine.count') do
      post :create, :invoice_line => @invoice_line.attributes
    end

    assert_redirected_to invoice_line_path(assigns(:invoice_line))
  end

  test "should show invoice_line" do
    get :show, :id => @invoice_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @invoice_line.to_param
    assert_response :success
  end

  test "should update invoice_line" do
    put :update, :id => @invoice_line.to_param, :invoice_line => @invoice_line.attributes
    assert_redirected_to invoice_line_path(assigns(:invoice_line))
  end

  test "should destroy invoice_line" do
    assert_difference('InvoiceLine.count', -1) do
      delete :destroy, :id => @invoice_line.to_param
    end

    assert_redirected_to invoice_lines_path
  end
end
