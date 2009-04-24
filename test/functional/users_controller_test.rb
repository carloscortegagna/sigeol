require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
   @user = User.new
   @user.stubs(:id => :an_id, :mail => :a_mail, :password => :a_password)
   @user.stubs(:active?).returns(true)
   User.stubs(:find).with(:an_id).returns(@user)
  end

  test"Guest usa edit"do
    get :edit,:id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test"Guest usa update"do
    put :update,:id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test"User loggato usa edit"do
    @request.session[:user_id] = :an_id
    get :edit,:id=>:an_id
    assert_response :success
    assert_template 'edit'
   end

   test"User loggato usa update ed aggiorna correttamente la password"do
      @request.session[:user_id] = :an_id
      @user.stubs(:update_attributes).returns(true)
      put :update,:id=>:an_id
      assert_equal flash[:notice], "Password cambiata con successo"
      assert_redirected_to timetables_url
   end

   test"User loggato usa update ed aggiorna non correttamente la password"do
      @request.session[:user_id] = :an_id
      @user.stubs(:update_attributes).returns(false)
      put :update,:id=>:an_id
      assert_template 'edit'
    end

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
    
end
