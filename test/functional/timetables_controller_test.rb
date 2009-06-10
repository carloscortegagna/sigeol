require 'test_helper'

class TimetablesControllerTest < ActionController::TestCase
 include TimetablesHelper
  
  #>>> GLI ID DEI TEST SEGUONO QUELLI DI USERS <<
  #>>> ID = 188 è il primo <<

  #ID = 188
  test "Guest usa Index" do
    TimetablesHelper.current_year
  end

  test "Guest usa show" do
    t = Time.now.advance(:months => 5)
   Time.stubs(:now).returns(t)
   TimetablesHelper.current_year
   TimetablesController.index
  end
end
