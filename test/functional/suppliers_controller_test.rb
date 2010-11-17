require 'test_helper'

class SuppliersControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @supplier = Factory :supplier, :project => @project
  end

  test "should get index" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:suppliers)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param
    assert_response :success
  end

  test "should create supplier" do
    assert_difference('Supplier.count') do
      post :create, :project_id => @project.to_param, :supplier => @supplier.attributes
    end

    assert_redirected_to project_supplier_path(@project, assigns(:supplier))
  end

  test "should show supplier" do
    get :show, :project_id => @project.to_param, :id => @supplier.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @supplier.to_param
    assert_response :success
  end

  test "should update supplier" do
    put :update, :project_id => @project.to_param, :id => @supplier.to_param, :supplier => @supplier.attributes
    assert_redirected_to project_supplier_path(@project, assigns(:supplier))
  end

  test "should destroy supplier" do
    assert_difference('Supplier.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @supplier.to_param
    end

    assert_redirected_to project_suppliers_path(@project)
  end
end
