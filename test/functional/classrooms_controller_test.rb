require 'test_helper'

class ClassroomsControllerTest < ActionController::TestCase

  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:classrooms)
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

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create classroom" do
    assert_difference('Classroom.count') do
      post :create, :classroom => { }
    end

    assert_redirected_to classroom_path(assigns(:classroom))
  end

  test "should show classroom" do
    get :show, :id => classrooms(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => classrooms(:one).id
    assert_response :success
  end

  test "should update classroom" do
    put :update, :id => classrooms(:one).id, :classroom => { }
    assert_redirected_to classroom_path(assigns(:classroom))
  end

  test "should destroy classroom" do
    assert_difference('Classroom.count', -1) do
      delete :destroy, :id => classrooms(:one).id
    end

    assert_redirected_to classrooms_path
  end
=end
end
