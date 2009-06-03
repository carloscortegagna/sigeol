require 'test_helper'

class TimetablesControllerTest < ActionController::TestCase

  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:timetables)
  end
end
