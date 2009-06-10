require 'test_helper'

class UsersControllerTest < ActionController::TestCase
require 'digest/sha1'
include UsersHelper
  def setup
   @user = User.new
   @user.stubs(:id => :an_id, :mail => :a_mail, :password => :a_password)
   @user.stubs(:active?).returns(true)
   User.stubs(:find).with(:an_id).returns(@user)
  end

  #ID = 182
  test"Guest usa edit"do
    get :edit,:id=>:an_id
    show_not_active_users(User.new)
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

  #ID = 183
  test"Guest usa update"do
    put :update,:id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

  #ID = 184
  test"User loggato usa edit"do
    @request.session[:user_id] = :an_id
    get :edit,:id=>:an_id
    assert_response :success
    assert_template 'edit'
   end

  #ID = 185
  test"User loggato usa update ed aggiorna correttamente la password"do
      @request.session[:user_id] = :an_id
      @user.stubs(:update_attributes).returns(true)
      @user.stubs(:password).returns(Digest::SHA1.hexdigest('123456'))
      put :update,:id=>:an_id, :old_password=>'', :user=>{:password=>"123456"},:repeat_password=>"123456", :old_password => "123456"
      assert_equal flash[:notice], "Password cambiata con successo"
      assert_redirected_to timetables_url
   end

  #ID = 186
  test"User loggato usa update ed aggiorna non correttamente la password"do
      @request.session[:user_id] = :an_id
      @user.stubs(:update_attributes).returns(false)
      put :update,:id=>:an_id,:old_password => "123456", :user=>{:password=>"123456"}
      assert_template 'edit'
    end

  #ID = 187
  test"User loggato tenta di modificare un altro user"do
    user = User.new
    user.stubs(:id => :another_id, :mail => :a_mail, :password => :a_password)
    User.stubs(:find).with(:another_id).returns(user)
    @request.session[:user_id] = :an_id
    put :update,:id=>:another_id
    assert_equal flash[:error], "Non puoi modificare un utente diverso dal tuo"
    assert_redirected_to timetables_url
    get :edit,:id=>:another_id
    assert_equal flash[:error], "Non puoi modificare un utente diverso dal tuo"
    assert_redirected_to timetables_url
  end
  private
    def render(a)
      a = "Sigeol"
    end
  end
