require File.dirname(__FILE__) + '/../test_helper'

class TagsControllerTest < ActionController::TestCase
  setup do
    @tag = Factory :tag
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tags)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create tag" do
    assert_difference('Tag.count') do
      post :create, :tag => {
        :name => 'blah'
      }
    end

    assert_redirected_to tag_path(assigns(:tag))
  end

  test "should show tag" do
    get :show, :id => @tag.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @tag.to_param
    assert_response :success
  end

  test "should update tag" do
    put :update, :id => @tag.to_param, :tag => @tag.attributes
    assert_redirected_to tag_path(assigns(:tag))
  end

  test "should destroy tag" do
    assert_difference('Tag.count', -1) do
      delete :destroy, :id => @tag.to_param
    end

    assert_redirected_to tags_path
  end
end
