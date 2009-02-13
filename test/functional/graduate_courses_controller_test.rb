require 'test_helper'

class GraduateCoursesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:graduate_courses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

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
end
