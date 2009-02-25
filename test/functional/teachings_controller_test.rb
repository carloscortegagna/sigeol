require 'test_helper'

class TeachingsControllerTest < ActionController::TestCase

  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teachings)
  end

  test "Guest usa Administration" do  #Redirect alla pagina di login
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa New" do  #Redirect alla pagina di login
    get :new
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

=begin

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
=end
end
