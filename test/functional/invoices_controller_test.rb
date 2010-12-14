require File.dirname(__FILE__) + '/../test_helper'

class InvoicesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @invoice = Factory :invoice, :project => @project
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:invoices)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param
    assert_response :success
  end

  test "should create invoice" do
    assert_difference('Invoice.count') do
      post :create, :project_id => @project.to_param, :invoice => @invoice.attributes
    end

    assert_redirected_to project_invoice_path(@project, assigns(:invoice))
  end

  test "should show invoice" do
    get :show, :project_id => @project.to_param, :id => @invoice.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @invoice.to_param
    assert_response :success
  end

  test "should update invoice" do
    put :update, :project_id => @project.to_param, :id => @invoice.to_param, :invoice => @invoice.attributes
    assert_redirected_to project_invoice_path(@project, assigns(:invoice))
  end

  test "fail to update invoice" do
    put :update, :project_id => @project.to_param, :id => @invoice.to_param, :invoice => {
      :project_id => nil
    }
    assert_redirected_to project_invoice_path(@project, assigns(:invoice))
  end
  
  test "should accept costs" do
    @invoice.update_attributes(:date => Date::today)
    
    get :accept, :id => @invoice.to_param
    
    assert_redirected_to project_invoice_path(@project, assigns(:invoice))
    assert_equal 'costs_specified', assigns(:invoice).state
  end
  
  test "should destroy invoice" do
    assert_difference('Invoice.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @invoice.to_param
    end

    assert_redirected_to project_invoices_path(@project)
  end
end
