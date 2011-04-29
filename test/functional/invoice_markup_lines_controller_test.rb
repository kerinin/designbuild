require 'test_helper'

class InvoiceMarkupLinesControllerTest < ActionController::TestCase
  setup do
    @invoice_markup_line = invoice_markup_lines(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_markup_lines)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice_markup_line" do
    assert_difference('InvoiceMarkupLine.count') do
      post :create, :invoice_markup_line => @invoice_markup_line.attributes
    end

    assert_redirected_to invoice_markup_line_path(assigns(:invoice_markup_line))
  end

  test "should show invoice_markup_line" do
    get :show, :id => @invoice_markup_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @invoice_markup_line.to_param
    assert_response :success
  end

  test "should update invoice_markup_line" do
    put :update, :id => @invoice_markup_line.to_param, :invoice_markup_line => @invoice_markup_line.attributes
    assert_redirected_to invoice_markup_line_path(assigns(:invoice_markup_line))
  end

  test "should destroy invoice_markup_line" do
    assert_difference('InvoiceMarkupLine.count', -1) do
      delete :destroy, :id => @invoice_markup_line.to_param
    end

    assert_redirected_to invoice_markup_lines_path
  end
end
