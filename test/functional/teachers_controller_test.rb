require 'test_helper'

class TeachersControllerTest < ActionController::TestCase

  test "Guest usa Index" do
    get :index
    assert_response :success
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

end