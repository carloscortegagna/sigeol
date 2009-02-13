require 'test_helper'

class TeachingsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teachings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create teaching" do
    assert_difference('Teaching.count') do
      post :create, :teaching => { }
    end

    assert_redirected_to teaching_path(assigns(:teaching))
  end

  test "should show teaching" do
    get :show, :id => teachings(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => teachings(:one).id
    assert_response :success
  end

  test "should update teaching" do
    put :update, :id => teachings(:one).id, :teaching => { }
    assert_redirected_to teaching_path(assigns(:teaching))
  end

  test "should destroy teaching" do
    assert_difference('Teaching.count', -1) do
      delete :destroy, :id => teachings(:one).id
    end

    assert_redirected_to teachings_path
  end
end
