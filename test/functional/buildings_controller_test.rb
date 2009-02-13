require 'test_helper'

class BuildingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:buildings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create building" do
    assert_difference('Building.count') do
      post :create, :building => { }
    end

    assert_redirected_to building_path(assigns(:building))
  end

  test "should show building" do
    get :show, :id => buildings(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => buildings(:one).id
    assert_response :success
  end

  test "should update building" do
    put :update, :id => buildings(:one).id, :building => { }
    assert_redirected_to building_path(assigns(:building))
  end

  test "should destroy building" do
    assert_difference('Building.count', -1) do
      delete :destroy, :id => buildings(:one).id
    end

    assert_redirected_to buildings_path
  end
end
