require File.dirname(__FILE__) + '/../test_helper'

class LaborersControllerTest < ActionController::TestCase
  setup do
    @project = Factory :project
    @laborer = Factory :laborer, :project => @project
    sign_in Factory :user
  end

  test "should get index" do
    get :index, :project_id => @project.to_param
    assert_response :success
    assert_not_nil assigns(:laborers)
  end

  test "should get new" do
    get :new, :project_id => @project.to_param
    assert_response :success
  end

  test "should get xhr new" do
    xhr :get, :new, :project_id => @project.to_param
    assert_response :success
    assert_template :new
    assert_equal 'text/javascript', response.content_type
  end
  
  test "should create laborer" do
    assert_difference('Laborer.count') do
      post :create, :project_id => @project.to_param, :laborer => {
        :name => 'bob', :bill_rate => 18
      }
    end

    assert_redirected_to project_laborer_path(@project, assigns(:laborer))
  end

  test "should create xhr laborer" do
    assert_difference('Laborer.count') do
      xhr :post, :create, :project_id => @project.to_param, :laborer => {
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
      xhr :post, :create, :project_id => @project.to_param, :laborer => {
        :name => 'bob', :bill_rate => nil
      }
    end

    assert_response :success
    assert_template :create
    assert_equal 'text/javascript', response.content_type
    assert response.body.include? '//Error'
  end
  
  test "should show laborer" do
    get :show, :project_id => @project.to_param, :id => @laborer.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :project_id => @project.to_param, :id => @laborer.to_param
    assert_response :success
  end

  test "should update laborer" do
    put :update, :project_id => @project.to_param, :id => @laborer.to_param, :laborer => @laborer.attributes
    assert_redirected_to project_laborer_path(@project, assigns(:laborer))
  end

  test "should destroy laborer" do
    assert_difference('Laborer.count', -1) do
      delete :destroy, :project_id => @project.to_param, :id => @laborer.to_param
    end

    assert_redirected_to project_laborers_path(@project)
  end
end
