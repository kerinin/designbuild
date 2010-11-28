require File.dirname(__FILE__) + '/../test_helper'

class QuantitiesControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @component = Factory :component, :project => @project
    @quantity = Factory :quantity, :component => @component
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :component_id => @component.to_param
    assert_response :success
    assert_not_nil assigns(:quantities)
  end

  test "should get new" do
    get :new, :component_id => @component.to_param
    assert_response :success
  end

  test "should xhr get new" do
    xhr :get, :new, :component_id => @component.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should create quantity" do
    assert_difference('Quantity.count') do
      post :create, :component_id => @component.to_param, :quantity => {
        :name => 'blah', :value => 10, :unit => 'ft'
      }
    end

    assert_redirected_to component_quantity_path(@component, assigns[:quantity])
  end

  test "should xhr create quantity" do
    assert_difference('Quantity.count') do
      xhr :post, :create, :component_id => @component.to_param, :quantity => {
        :name => 'blah', :value => 10, :unit => 'ft'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr quantity" do
    assert_no_difference('Quantity.count') do
      xhr :post, :create, :component_id => @component.to_param, :quantity => {
        :name => 'blah', :value => nil, :unit => 'ft'
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show quantity" do
    get :show, :component_id => @component.to_param, :id => @quantity.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :component_id => @component.to_param, :id => @quantity.to_param
    assert_response :success
  end

  test "should xhr get edit" do
    xhr :get, :edit, :component_id => @component.to_param, :id => @quantity.to_param
    assert_response :success
    assert_template :edit
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should update quantity" do
    put :update, :component_id => @component.to_param, :id => @quantity.to_param, :quantity => @quantity.attributes
    assert_redirected_to project_component_path(@project, @component)
  end

  test "should xhr update quantity" do
    xhr :put, :update, :component_id => @component.to_param, :id => @quantity.to_param, :quantity => @quantity.attributes
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end

  test "should fail to xhr update quantity" do
    xhr :put, :update, :component_id => @component.to_param, :id => @quantity.to_param, :quantity => {
        :name => 'blah', :value => nil, :unit => 'ft'
      }
    
    assert_response :success
    assert_template :update
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should destroy quantity" do
    assert_difference('Quantity.count', -1) do
      delete :destroy, :component_id => @component.to_param, :id => @quantity.to_param
    end

    assert_redirected_to project_component_path(@project, @component)
  end
end
