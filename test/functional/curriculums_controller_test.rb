require 'test_helper'

class CurriculumsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:curriculums)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create curriculum" do
    assert_difference('Curriculum.count') do
      post :create, :curriculum => { }
    end

    assert_redirected_to curriculum_path(assigns(:curriculum))
  end

  test "should show curriculum" do
    get :show, :id => curriculums(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => curriculums(:one).id
    assert_response :success
  end

  test "should update curriculum" do
    put :update, :id => curriculums(:one).id, :curriculum => { }
    assert_redirected_to curriculum_path(assigns(:curriculum))
  end

  test "should destroy curriculum" do
    assert_difference('Curriculum.count', -1) do
      delete :destroy, :id => curriculums(:one).id
    end

    assert_redirected_to curriculums_path
  end
end