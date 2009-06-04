require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  #ID = 108
  test "Guest usa New" do
    get :new
    assert_template "new"
    assert_response :success
  end

  #ID = 109
  test "Immissione di email e password validi" do
    user = stub(:id => :an_id, :mail => "a_mail", :password => "a_password")
    User.stubs(:authenticate).returns(user)
    user.stubs(:active?).returns(true)
    post :create, :mail => user.mail, :password => user.password
    assert_equal session[:user_id], :an_id
    assert_redirected_to timetables_url
  end

  #ID = 110
  test"Immissione di email e password non validi"do
    user = User.stubs(:authenticate).returns(nil)
    post :create, :mail => :a_mail, :password => :a_password
    assert_equal flash[:error], "E-mail o password errati."
    assert_template 'new'
  end

  #ID = 111
  test"logout di uno user"do
    delete :destroy,:id=>:an_id
    assert_equal flash[:notice], "Logout effettuato con successo."
    assert_redirected_to new_session_url
  end
end
