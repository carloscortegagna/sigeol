require 'test_helper'

class BuildingsControllerTest < ActionController::TestCase

  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:buildings)
  end

  test "Guest usa Administration" do  #Redirect alla pagina di login
    get :administration
    assert_redirected_to new_session_url
    flash[:notice] = "Effettuare il login"
  end

  test "Guest usa New" do  #Redirect alla pagina di login
    get :new
    assert_redirected_to new_session_url
    flash[:notice] = "Effettuare il login"
  end

=begin
  test "Guest usa Destroy" do  #Redirect alla pagina di login
    get :destroy, :id => buildings(:test_building_1).id
    assert_redirected_to new_session_url
    flash[:notice] = "Effettuare il login"
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
=end
end
