require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "Guest usa New" do
    get :new
    assert_template "new"
    assert_response :success
  end

  test "Immissione di email e password validi" do
    user = stub(:id => :an_id, :mail => "a_mail", :password => "a_password")
    User.stubs(:authenticate).returns(user)
    user.stubs(:active?).returns(true)
    post :create, :mail => user.mail, :password => user.password
    assert_equal session[:user_id], :an_id
    assert_redirected_to timetables_url
  end
end
