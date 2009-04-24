require 'test_helper'

class TeachingsControllerTest < ActionController::TestCase

  def setup
   @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
   @user.stubs(:active?).returns(true)
   User.stubs(:find).returns(@user)
   @user.stubs(:manage_teachings?).returns(true)
  end

  test "Guest usa Index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:teachings)
  end

  test"Guest usa show"do
    t = Teaching.new
    t.stubs(:id=>:an_id,:name=>:a_name)
    Teaching.stubs(:find).with(:an_id).returns(t)
    get :show,:id=>:an_id
  end

  test "Guest usa Administration" do
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa New" do
    get :new
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test"Guest usa create"do
    get :create
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test"Guest usa select_teacher"do
    get :select_teacher, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

    test"Guest usa assign_teacher"do
      put :assign_teacher,:id=>:an_id,:teacher_id=>:a_teacher_id
      assert_redirected_to new_session_url
      assert_equal "Effettuare il login" , flash[:notice]
    end

   test"Guest usa update"do
      put :update,:id=>:an_id
      assert_redirected_to new_session_url
      assert_equal "Effettuare il login" , flash[:notice]
    end

  test"Guest usa destroy"do
      delete :destroy,:id=>:an_id
      assert_redirected_to new_session_url
      assert_equal "Effettuare il login" , flash[:notice]
  end

  test"User con privilegi usa administration"do
    gc = GraduateCourse.new
    gc.stubs(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    t = Teaching.new
    t.stubs(:id=>:an_id,:name=>:a_name)
    @request.session[:user_id] = :an_id
    @user.stubs(:graduate_courses).returns([gc])
    gc.stubs(:curriculums).returns([c])
    c.stubs(:teachings).returns([t])
    get :administration
    assert_template 'administration'
    assert_response :success
  end

  test"User con privilegi usa new"do
    t = Teaching.new(:id=>:an_id,:name=>:a_name)
    gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    @request.session[:user_id] = :an_id
    @user.stubs(:graduate_courses).returns([gc])
    get :new
    assert_template 'new'
    assert_response :success
  end

  test"User con privilegi usa edit"do
    gc  = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.stubs(:find).returns([gc])
    t = Teaching.new
    t.stubs(:id=>:an_id,:name=>:a_name)
    Teaching.stubs(:find).with(:an_id).returns(t)
    @request.session[:user_id] = :an_id
    get :edit,:id=>:an_id
    assert_response :success
    assert_template 'edit'
  end

  test"User con privilegi crea un insegnamento corretto(metodo create)"do
    t = Teaching.new
    c = Curriculum.new(:id=>:another_id,:name=>:a_name)
    p = Period.new(:id=>:another_id,:year=>:a_year,:subperiod=>:a_period)
    Curriculum.stubs(:find).with(:another_id).returns(c)
    Period.stubs(:find_by_subperiod_and_year).with(:a_subperiod,:a_year).returns(p)
    @request.session[:user_id] = :an_id
    Teaching.any_instance.stubs(:save).returns(true)
    post :create,:teaching=>{:name=>:a_name},:curriculum_id=>:another_id,:subperiod=>:a_subperiod,:year=>:a_year
    assert_equal flash[:notice], 'Insegnamento creato correttamente.'
    assert_redirected_to select_teacher_teaching_url(t)
  end

  test"User con privilegi crea un insegnamento non valido(metodo create)"do
    c = Curriculum.new(:id=>:another_id,:name=>:a_name)
    p = Period.new(:id=>:another_id,:year=>:a_year,:subperiod=>:a_period)
    gc = GraduateCourse.new(:id=>:another_id,:name=>:a_name,:duration=>:a_duration)
    Curriculum.stubs(:find).with(:another_id).returns(c)
    Period.stubs(:find_by_subperiod_and_year).with(:a_subperiod,:a_year).returns(p)
    @request.session[:user_id] = :an_id
    Teaching.any_instance.stubs(:save).returns(false)
    @user.stubs(:graduate_courses).returns([gc])
    post :create,:teaching=>{:name=>:a_name},:curriculum_id=>:another_id,:subperiod=>:a_subperiod,:year=>:a_year
    assert_template 'new'
  end

  test"User con privilegi usa select_teacher"do
    gc  = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.stubs(:find).returns([gc])
    t = Teaching.new(:id=>:an_id,:name=>:a_name)
    Teaching.stubs(:find).with(:an_id).returns(t)
    @request.session[:user_id] = :an_id
    get :select_teacher, :id=>:an_id
    assert_template 'select_teacher'
  end
  
  test"User con privilegi assegna correttamente un docente(metodo assign_teacher)"do
    gc  = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.stubs(:find).returns([gc])
    @request.session[:user_id] = :an_id
    teacher = Teacher.new
    teaching = Teaching.new
   Teacher.stubs(:find).with(:a_teacher_id).returns(teacher)
   Teaching.stubs(:find).with(:an_id).returns(teaching)
   teaching.stubs(:save).returns(true)
    put :assign_teacher,:id=>:an_id,:teacher_id=>:a_teacher_id
    assert_equal flash[:notice], "Docente assegnato con successo"
    assert_redirected_to administration_teachings_url
  end

   test"User con privilegi non assegna correttamente un docente(metodo assign_teacher)"do
    gc  = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.stubs(:find).returns([gc])
    @request.session[:user_id] = :an_id
    teacher = Teacher.new
    teaching = Teaching.new
   Teacher.stubs(:find).with(:a_teacher_id).returns(teacher)
   Teaching.stubs(:find).with(:an_id).returns(teaching)
   teaching.stubs(:save).returns(false)
   put :assign_teacher,:id=>:an_id,:teacher_id=>:a_teacher_id
   assert_redirected_to select_teacher_teaching_url(teaching)
  end

  test"User con privilegi aggiorna correttamente un insegnamento(metodo update)"do
     gc  = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.stubs(:find).returns([gc])
     teaching = Teaching.new
    @request.session[:user_id] = :an_id
    Teaching.stubs(:find).with(:an_id).returns(teaching)
    teaching.stubs(:update_attributes).returns(true)
    put :update,:id=>:an_id
   assert_equal  flash[:notice], 'Teaching was successfully updated.'
   assert_redirected_to(teaching)
  end

  test"User con privilegi aggiorna non correttamente un insegnamento(metodo update)"do
     gc  = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.stubs(:find).returns([gc])
     teaching = Teaching.new
    @request.session[:user_id] = :an_id
    Teaching.stubs(:find).with(:an_id).returns(teaching)
    teaching.stubs(:update_attributes).returns(false)
    put :update,:id=>:an_id
   assert_template 'edit'
  end

  test"User con privilegi utilizza destroy"do
     gc  = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.stubs(:find).returns([gc])
     teaching = Teaching.new
    @request.session[:user_id] = :an_id
    Teaching.stubs(:find).with(:an_id).returns(teaching)
    delete :destroy,:id=>:an_id
    assert_redirected_to(administration_teachings_url)
  end

  #user con same_graduate_course_required uguale a false
  test"User tenta di modificare un insegnamento che non appartiene ad un suo stesso corso di laurea"do
    @request.session[:user_id] = :an_id
    get :edit,:id=>:an_id
   assert_equal flash[:error], "Questo insegnamento non appartiane a nessun tuo corso di laurea"
   assert_redirected_to timetables_url
   put :update,:id=>:an_id
   assert_equal flash[:error], "Questo insegnamento non appartiane a nessun tuo corso di laurea"
   assert_redirected_to timetables_url
 end

  test"User tenta di eliminare un insegnamento che non appartiene ad un suo stesso corso di laurea"do
    @request.session[:user_id] = :an_id
    delete :destroy,:id=>:an_id
    assert_equal flash[:error], "Questo insegnamento non appartiane a nessun tuo corso di laurea"
    assert_redirected_to timetables_url
  end
  
  test"User tenta di assegnare un decente ad un insegnamento che non appartiene ad un suo stesso corso di laurea"do
    @request.session[:user_id] = :an_id
    get :select_teacher, :id=>:an_id
    assert_equal flash[:error], "Questo insegnamento non appartiane a nessun tuo corso di laurea"
    assert_redirected_to timetables_url
    put :assign_teacher,:id=>:an_id,:teacher_id=>:a_teacher_id
    assert_equal flash[:error], "Questo insegnamento non appartiane a nessun tuo corso di laurea"
    assert_redirected_to timetables_url
  end

  test"User senza il privilegio di poter modificare un insegnamento usa administration"do
    @user.stubs(:manage_teachings?).returns(false)
    @request.session[:user_id] = :an_id
    get :administration
    assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

   test"User senza il privilegio di poter modificare un insegnamento usa new"do
    @user.stubs(:manage_teachings?).returns(false)
    @request.session[:user_id] = :an_id
    get :new
    assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

   test"User senza il privilegio di poter modificare un insegnamento usa edit"do
    @user.stubs(:manage_teachings?).returns(false)
    @request.session[:user_id] = :an_id
    get :edit, :id=>:an_id
    assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

   test"User senza il privilegio di poter modificare un insegnamento usa create"do
    @user.stubs(:manage_teachings?).returns(false)
    @request.session[:user_id] = :an_id
    post :create, :id=>:an_id
    assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

   test"User senza il privilegio di poter modificare un insegnamento usa select_teacher"do
    @user.stubs(:manage_teachings?).returns(false)
    @request.session[:user_id] = :an_id
    get :select_teacher, :id=>:an_id
    assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

   test"User senza il privilegio di poter modificare un insegnamento usa assign_teacher"do
    @user.stubs(:manage_teachings?).returns(false)
    @request.session[:user_id] = :an_id
    post :assign_teacher, :id=>:an_id
    assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

   test"User senza il privilegio di poter modificare un insegnamento usa update"do
    @user.stubs(:manage_teachings?).returns(false)
    @request.session[:user_id] = :an_id
    put :update, :id=>:an_id
    assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

   test"User senza il privilegio di poter modificare un insegnamento usa destroy"do
    @user.stubs(:manage_teachings?).returns(false)
    @request.session[:user_id] = :an_id
    delete :destroy, :id=>:an_id
    assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end
end