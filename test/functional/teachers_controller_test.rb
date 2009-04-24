require 'test_helper'

class TeachersControllerTest < ActionController::TestCase

  def setup
   @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
   @user.stubs(:active?).returns(true)
   User.stubs(:find).returns(@user)
  end

  test "Guest usa index" do
    get :index
    assert_template "index"
    assert_response :success
  end

  test "Guest usa show" do
    teacher = stub(:name => :a_name, :id => :an_id, :surname => :a_surname)
    teaching = stub(:name => :teaching_name)
    Teacher.expects(:find).returns(teacher)
    teacher.stubs(:teachings).returns([teaching])
    get :show, :id => teacher
    assert_response :success
  end

  test"Utilizzo di pre_activate"do
    User.stubs(:find).returns(nil)
    get :pre_activate, :id=>:an_id,:digest=>:a_digest
    assert_equal flash[:notice], "Questo docente è già attivo o non esiste"
    assert_redirected_to timetables_url
  end

  test"Utilizzo di activate(Account attivato correttamente)"do
    user = User.new(:digest=>:a_digest)
    User.stubs(:find).with(:an_id).returns(user)
    user.stubs(:specified_type).returns("Teacher")
    user.stubs(:active?).returns(false)
    user.address.stubs(:update_attributes).returns(true)
    user.stubs(:save).returns(true)
    post :activate, :id=>:an_id, :digest=>:a_digest,:user=>{:password=>:a_password}
    assert flash[:notice], "Account attivato correttamente"
    assert_redirected_to timetables_url
  end

  test"Utilizzo di active(Attivazione di un account già esistente)"do
    user = User.new(:digest=>:a_digest)
    User.stubs(:find).with(:an_id).returns(user)
    user.stubs(:specified_type).returns("Teacher")
    user.stubs(:active?).returns(true)
    post :activate, :id=>:an_id, :digest=>:a_digest,:user=>{:password=>:a_password}
    assert_equal flash[:error], "L'utente non esiste od è già attivo"
    assert_redirected_to timetables_url
  end

  test"Utilizzo di active(Campo indirizzo inserito non correttamente)" do
    user = User.new(:digest=>:a_digest)
    User.stubs(:find).with(:an_id).returns(user)
    user.stubs(:specified_type).returns("Teacher")
    user.stubs(:active?).returns(false)
    user.address.stubs(:update_attributes).returns(false)
    post :activate, :id=>:an_id, :digest=>:a_digest,:user=>{:password=>:a_password}
    assert_template 'pre_activate'
  end

  test"Utilizzo di active(Alcuni campi di user non sono validi)" do
    user = User.new(:digest=>:a_digest)
    User.stubs(:find).with(:an_id).returns(user)
    user.stubs(:specified_type).returns("Teacher")
    user.stubs(:active?).returns(false)
    user.address.stubs(:update_attributes).returns(true)
    user.stubs(:save).returns(false)
    post :activate, :id=>:an_id, :digest=>:a_digest,:user=>{:password=>:a_password}
    assert_template 'pre_activate'
  end

  test "Guest usa administration" do  #Redirect alla pagina di login
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa new" do  #Redirect alla pagina di login
    get :new
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Utente con privilegi usa new" do
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

  test "Utente con privilegi aggiunge docente nuovo(metodo create)" do
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
    assert_equal flash[:notice], "Docente invitato con successo"
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

  test"Utente con privilegi usa metodo administration"do
    @user.stubs(:manage_teachers?).returns(true)
    @request.session[:user_id] = :an_id
    @user.stubs(:manage_teachers?).returns(true)
    gc = GraduateCourse.new(:name=>:a_name,:duration=>:a_duration)
    gc.stubs(:id=>:an_id)
    user_not_active = User.new(:id=>:another_id,:mail=>:a_mail)
    GraduateCourse.stubs(:find).returns([gc])
    User.stubs(:find).with(:all).returns([user_not_active])
    get :administration
    assert_response :success
    assert_template 'administration'
  end

  test"User con privilegi usa edit_capabilities"do
    @user.stubs(:manage_capabilities?).returns(true)
    @request.session[:user_id] = :an_id
    t = Teacher.new
    t.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
    Teacher.stubs(:find).returns(t)
    t.user.stubs(:graduate_course_ids).returns([:an_id])
    @user.stubs(:graduate_course_ids).returns([:an_id])
   capability = Capability.new(:name=>:a_name)
   t.user.stubs(:capabilities).returns([capability])
   @user.stubs(:capabilities).returns([capability])
   get :edit_capabilities,:id=>:an_id
   assert_response :success
   assert_template 'edit_capabilities'
  end

  test"User con privilegi usa update_capabilities"do
     @user.stubs(:manage_capabilities?).returns(true)
     @request.session[:user_id] = :an_id
      t = Teacher.new
      t.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
     Teacher.stubs(:find).returns(t)
      t.user.stubs(:graduate_course_ids).returns([:an_id])
      @user.stubs(:graduate_course_ids).returns([:an_id])
      capability = Capability.new(:name=>:a_name)
      t.user.stubs(:capabilities).returns([capability])
     @user.stubs(:capabilities).returns([capability])
     Capability.stubs(:find).returns([:an_id])
     delete :update_capabilities,:id=>:an_id,:ids=>[:an_id]
     assert_equal flash[:notice], "Privilegi per il docente #{t.surname} #{t.name} aggiornati con successo"
     put :update_capabilities,:id=>:an_id,:ids=>[:an_id]
     assert_equal flash[:notice], "Privilegi per il docente #{t.surname} #{t.name} aggiornati con successo"
  end

  test"User con privilegi usa edit_graduate_courses"do
     @user.stubs(:manage_teachers?).returns(true)
     @request.session[:user_id] = :an_id
      t = Teacher.new
      t.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
      gc = GraduateCourse.new(:name=>:a_name,:duration=>:a_duration)
     Teacher.stubs(:find).returns(t)
      t.user.stubs(:graduate_course_ids).returns([:an_id])
      @user.stubs(:graduate_course_ids).returns([:an_id])
      t.user.stubs(:graduate_courses).returns([gc])
      @user.stubs(:graduate_courses).returns([gc])
      get :edit_graduate_courses, :id=>:an_id
      assert_response :success
      assert_template 'edit_graduate_courses'
  end

  test"User con privilegi usa update_graduate_courses"do
      @user.stubs(:manage_teachers?).returns(true)
      @request.session[:user_id] = :an_id
      t = Teacher.new
      t.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
      gc = GraduateCourse.new(:name=>:a_name,:duration=>:a_duration)
     Teacher.stubs(:find).returns(t)
      t.user.stubs(:graduate_course_ids).returns([:an_id])
      @user.stubs(:graduate_course_ids).returns([:an_id])
      gc = GraduateCourse.new(:name=>:a_name,:duration=>:a_duration)
      t.user.stubs(:graduate_courses).returns([gc])
      @user.stubs(:graduate_courses).returns([gc])
      GraduateCourse.stubs(:find).with([:an_id]).returns([gc])
      delete :update_graduate_courses,:id=>:an_id,:ids=>[:an_id]
      assert_equal flash[:notice], "Corsi di laurea per il docente #{t.surname} #{t.name} aggiornati con successo"
      assert_redirected_to administration_teachers_url
      put :update_graduate_courses,:id=>:an_id,:ids=>[:an_id]
      assert_equal flash[:notice], "Corsi di laurea per il docente #{t.surname} #{t.name} aggiornati con successo"
      assert_redirected_to administration_teachers_url
  end
  
  test"User con privilegi usa edit_constraints"do
    @request.session[:user_id] = :an_id
    t = Teacher.new
    t.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
    
  end

end
