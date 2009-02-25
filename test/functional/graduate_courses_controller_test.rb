require 'test_helper'

class GraduateCoursesControllerTest < ActionController::TestCase
  
  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:graduate_courses)
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

  test "should create graduate_course" do
    assert_difference('GraduateCourse.count') do
      post :create, :graduate_course => { }
    end

    assert_redirected_to graduate_course_path(assigns(:graduate_course))
  end

  test "should show graduate_course" do
    get :show, :id => graduate_courses(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => graduate_courses(:one).id
    assert_response :success
  end

  test "should update graduate_course" do
    put :update, :id => graduate_courses(:one).id, :graduate_course => { }
    assert_redirected_to graduate_course_path(assigns(:graduate_course))
  end

  test "should destroy graduate_course" do
    assert_difference('GraduateCourse.count', -1) do
      delete :destroy, :id => graduate_courses(:one).id
    end

    assert_redirected_to graduate_courses_path
  end
=end
end
