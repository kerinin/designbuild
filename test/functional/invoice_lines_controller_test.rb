require File.dirname(__FILE__) + '/../test_helper'

class InvoiceLinesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @contract = Factory :contract, :project => @project
    @invoice = Factory :invoice, :project => @project
    
    @invoice_line = Factory :invoice_line, :invoice => @invoice, :cost => @contract
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :invoice_id => @invoice.to_param
    assert_response :success
    assert_not_nil assigns(:invoice_lines)
  end

  test "should get new" do
    get :new, :invoice_id => @invoice.to_param
    assert_response :success
  end

  test "should create invoice_line" do
    assert_difference('InvoiceLine.count') do
      post :create, :invoice_id => @invoice.to_param, :invoice_line => @invoice_line.attributes
    end

    assert_redirected_to invoice_line_item_path(@invoice, assigns(:invoice_line))
  end

  test "should show invoice_line" do
    get :show, :invoice_id => @invoice.to_param, :id => @invoice_line.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :invoice_id => @invoice.to_param, :id => @invoice_line.to_param
    assert_response :success
  end

  test "should update invoice_line" do
    put :update, :invoice_id => @invoice.to_param, :id => @invoice_line.to_param, :invoice_line => @invoice_line.attributes
    assert_redirected_to invoice_line_item_path(@invoice, assigns(:invoice_line))
  end

  test "should destroy invoice_line" do
    assert_difference('InvoiceLine.count', -1) do
      delete :destroy, :invoice_id => @invoice.to_param, :id => @invoice_line.to_param
    end

    assert_redirected_to invoice_path(@invoice)
  end
end
