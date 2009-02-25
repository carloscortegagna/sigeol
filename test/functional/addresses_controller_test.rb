require 'test_helper'

class AddressesControllerTest < ActionController::TestCase

  test "Guest usa New" do  #Redirect alla pagina di login
    get :new
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end
  
=begin

  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:addresses)
  end

  test "should create address" do
    assert_difference('Address.count') do
      post :create, :address => { }
    end

    assert_redirected_to address_path(assigns(:address))
  end

  test "should show address" do
    get :show, :id => addresses(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => addresses(:one).id
    assert_response :success
  end

  test "should update address" do
    put :update, :id => addresses(:one).id, :address => { }
    assert_redirected_to address_path(assigns(:address))
  end

  test "should destroy address" do
    assert_difference('Address.count', -1) do
      delete :destroy, :id => addresses(:one).id
    end

    assert_redirected_to addresses_path
  end
=end
end
