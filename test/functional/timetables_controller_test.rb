require 'test_helper'

class TimetablesControllerTest < ActionController::TestCase

  
  #>>> GLI ID DEI TEST SEGUONO QUELLI DI USERS <<
  #>>> ID = 188 è il primo <<

  #ID = 188
  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:timetables)
  end
end
