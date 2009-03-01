require 'test_helper'

class TeachersControllerTest < ActionController::TestCase

  test "Guest usa Index" do
    get :index
    assert_template "index"
    assert_response :success
  end

  test "Guest usa Show" do
    teacher = stub(:name => :a_name, :id => :an_id, :surname => :a_surname)
    teaching = stub(:name => :teaching_name)
    Teacher.expects(:find).returns(teacher)
    teacher.stubs(:teachings).returns([teaching])
    get :show, :id => teacher
    assert_response :success
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

  test "Utente con privilegi usa New" do
    user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
    gs = stub(:id => :another_id, :name => :another_name)
    user.stubs(:active?).returns(true)
    user.stubs(:manage_teachers?).returns(true)
    user.stubs(:graduate_courses).returns([gs])
    User.stubs(:find).returns(user)
    @request.session[:user_id] = :an_id
    get :new
    assert_response :success
  end

  test "Utente con privilegi aggiunge docente nuovo" do
    user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password, :digest => :a_digest)
    gs = GraduateCourse.new
    gs.stubs(:id => :another_id, :name => :another_name)
    user.stubs(:active?).returns(true)
    user.stubs(:manage_teachers?).returns(true)
    user.stubs(:graduate_courses).returns([gs])
    User.stubs(:find).with(:an_id).returns(user)
    GraduateCourse.stubs(:find).with(:another_id).returns(gs)
    TeacherMailer.stubs(:deliver_activate_teacher)
    User.stubs(:find_by_mail).returns(nil)
    User.any_instance.stubs(:save).returns(true,false)
    @request.session[:user_id] = :an_id
    post :create, :mail => :teacher_mail, :graduate_course_id => :another_id
    assert_redirected_to new_teacher_url
    assert_not_nil flash[:notice]
    post :create, :mail => :teacher_mail, :graduate_course_id => :another_id
    assert_response :success
    assert_template "new"
  end

  test "Utente con privilegi aggiunge docente già esistente" do
    user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password, :digest => :a_digest)
    teacher = User.new
    gs = GraduateCourse.new
    gs.stubs(:id => :another_id, :name => :another_name)
    user.stubs(:active?).returns(true)
    user.stubs(:manage_teachers?).returns(true)
    user.stubs(:graduate_courses).returns([gs])
    User.stubs(:find).with(:an_id).returns(user)
    GraduateCourse.stubs(:find).with(:another_id).returns(gs)
    User.stubs(:find_by_mail).returns(teacher)
    teacher.stubs(:own_by_teacher?).returns(true,false)
    @request.session[:user_id] = :an_id
    post :create, :mail => :teacher_mail, :graduate_course_id => :another_id
    assert_redirected_to new_teacher_url
    assert_not_nil flash[:notice]
    post :create, :mail => :teacher_mail, :graduate_course_id => :another_id
    assert_redirected_to new_teacher_url
    assert_not_nil flash[:error]
  end
end