require File.dirname(__FILE__) + '/../test_helper'

class LaborersControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @laborer = Factory :laborer
    sign_in Factory :user
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:laborers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should get xhr new" do
    xhr :get, :new
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should create laborer" do
    assert_difference('Laborer.count') do
      post :create, :laborer => {
        :name => 'bob', :bill_rate => 18
      }
    end

    assert_redirected_to laborer_path(assigns(:laborer))
  end

  test "should create xhr laborer" do
    assert_difference('Laborer.count') do
      xhr :post, :create, :laborer => {
        :name => 'bob', :bill_rate => 18
      }
    end
    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Success'
  end
  
  test "should fail to create xhr material_cost" do
    assert_no_difference('Laborer.count') do
      xhr :post, :create, :laborer => {
        :name => 'bob', :bill_rate => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show laborer" do
    get :show, :id => @laborer.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @laborer.to_param
    assert_response :success
  end

  test "should update laborer" do
    put :update, :id => @laborer.to_param, :laborer => @laborer.attributes
    assert_redirected_to laborer_path(assigns(:laborer))
  end

  test "should destroy laborer" do
    assert_difference('Laborer.count', -1) do
      delete :destroy, :id => @laborer.to_param
    end

    assert_redirected_to laborers_path
  end
end
