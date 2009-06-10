require 'test_helper'

class TeachersControllerTest < ActionController::TestCase
include TeachersHelper
include ApplicationHelper
  def setup
   @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
   @user.stubs(:active?).returns(true)
   menu_admin
   User.stubs(:find).with(:an_id).returns(@user)
  end

 # ID = 112
  test "Guest usa index" do
    User.stubs(:find_by_specified_type).returns(@user)
    get :index
    assert_template "index"
    assert_response :success
  end

 # ID = 113
  test "Guest usa show" do
    teacher = stub(:name => :a_name, :id => :an_id, :surname => :a_surname)
    teaching = stub(:name => :teaching_name)
    a  = Address.new()
    @user.stubs(:address).returns(a)
    User.stubs(:find).returns(@user)
    show_teacher_admin(Teacher.new)
    Teacher.expects(:find).returns(teacher)
    teacher.stubs(:teachings).returns([teaching])
    get :show, :id => teacher
    assert_response :success
  end

  # ID = 114
  test"Utilizzo di pre_activate"do
    User.stubs(:find).returns(nil)
    get :pre_activate, :id=>:an_id,:digest=>:a_digest
    assert_equal flash[:notice], "Questo docente è già attivo o non esiste"
    assert_redirected_to timetables_url
  end

  # ID = 115
  test"Utilizzo di activate(Account attivato correttamente)"do
    user = User.new(:digest=>:a_digest)
    User.stubs(:find).with(:an_id).returns(user)
    user.stubs(:address).returns(Address.new)
    user.stubs(:specified).returns(Teacher.new)
    user.stubs(:specified_type).returns("Teacher")
    user.stubs(:active?).returns(false)
    show_teacher(Teacher.new)
    user.specified.stubs(:update_attributes).returns(true)
    user.address.stubs(:update_attributes).returns(true)
    user.stubs(:save).returns(true)
    post :activate, :id=>:an_id, :digest=>:a_digest,:user=>{:password=>:a_password},:prefisso=>'',:telefono=>'',:repeat_password=>:a_password
    assert flash[:notice], "Account attivato correttamente"
    assert_redirected_to timetables_url
  end

  # ID = 116
  test"Utilizzo di active(Attivazione di un account già esistente)"do
    user = User.new(:digest=>:a_digest)
    User.stubs(:find).with(:an_id).returns(user)
    user.stubs(:specified_type).returns("Teacher")
    user.stubs(:active?).returns(true)
    post :activate, :id=>:an_id, :digest=>:a_digest,:user=>{:password=>:a_password}
    assert_equal flash[:error], "L'utente non esiste od è già attivo"
    assert_redirected_to timetables_url
  end

  # ID = 117
  test"Utilizzo di active(Campo indirizzo inserito non correttamente)" do
    user = User.new(:digest=>:a_digest)
    User.stubs(:find).with(:an_id).returns(user)
    a =Address.new()
    t = Teacher.new()
    user.stubs(:address).returns(a)
    user.stubs(:specified).returns(t)
    user.stubs(:specified_type).returns("Teacher")
    user.stubs(:active?).returns(false)
    user.address.stubs(:update_attributes).returns(false)
    post :activate, :id=>:an_id, :digest=>:a_digest,:user=>{:password=>:a_password},:prefisso=>'049',:telefono=>'9075393'
    assert_template 'pre_activate'
  end

 # ID = 118
  test"Utilizzo di active(Alcuni campi di user non sono validi)" do
    user = User.new(:digest=>:a_digest)
    User.stubs(:find).with(:an_id).returns(user)
    a = Address.new
    t = Teacher.new
    user.stubs(:address).returns(a)
    user.stubs(:specified).returns(t)
    user.stubs(:specified_type).returns("Teacher")
    user.stubs(:active?).returns(false)
    user.address.stubs(:update_attributes).returns(true)
    user.specified.stubs(:update_attributes).returns(true)
    post :activate, :id=>:an_id, :digest=>:a_digest,:user=>{:password=>'pro?'},:prefisso=>'',:telefono=>'',:repeat_password=>'pro?'
    assert_template 'pre_activate'
  end

 # ID = 119
  test "Guest usa administration" do  #Redirect alla pagina di login
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 120
  test "Guest usa new" do  #Redirect alla pagina di login
    get :new
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 121
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

 # ID = 122
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

 # ID = 123
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

  # ID = 124
  test"Utente con privilegi usa metodo administration"do
    @user.stubs(:manage_teachers?).returns(true)
    @request.session[:user_id] = :an_id
    @user.stubs(:graduate_course_ids).returns(:an_id)
    @user.stubs(:own_by_teacher?).returns(true)
    @user.stubs(:manage_timetables?).returns(true)
    @user.stubs(:specified_id).returns(:an_id)
    gc = GraduateCourse.new(:name=>:a_name,:duration=>:a_duration)
    gc.stubs(:id=>:an_id)
    user_not_active = User.new(:id=>:another_id,:mail=>:a_mail)
    GraduateCourse.stubs(:find).returns([gc])
    User.stubs(:find).with(:all,:include => :graduate_courses,:conditions => ["users.password IS null AND graduate_courses.id IN (?)",:an_id]).returns([user_not_active])
    User.stubs(:find).with(:all, :include => :graduate_courses,:conditions => ["specified_type = 'Teacher' AND graduate_courses.id IS null AND users.password is NOT null"]).returns([])
    
    get :administration
    assert_response :success
    assert_template 'administration'
  end

  # ID = 125
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

  # ID = 126
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
     assert_template 'edit_capabilities'
    put :update_capabilities,:id=>:an_id,:ids=>[:an_id]
     assert_template 'edit_capabilities'
  end

  # ID = 127
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

  # ID = 128
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
      t.user.graduate_courses.stubs(:size).returns(0)
      delete :update_graduate_courses,:id=>:an_id,:ids=>[:an_id]
      assert_template 'edit_graduate_courses'
      put :update_graduate_courses,:id=>:an_id,:ids=>[:an_id]
      assert_template 'edit_graduate_courses'
  end


  # ID = 129
  test"User con privilegi tenta di associare un docente che non appartiene a nessun suo corso di laurea ad un altro corso di laurea"do
    @user.stubs(:manage_teachers?).returns(true)
    @user.stubs(:manage_capabilities?).returns(true)
    @request.session[:user_id] = :an_id
    t = Teacher.new
    t.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
    Teacher.stubs(:find).returns(t)
     t.user.stubs(:graduate_course_ids).returns([:an_id])
    @user.stubs(:graduate_course_ids).returns([:another_id])
    get  :edit_graduate_courses, :id=>:an_id
    assert_equal flash[:error], "Questo docente non appartiene a nessun tuo corso di laurea"
    assert_redirected_to timetables_url
    put  :update_graduate_courses, :id=>:an_id
    assert_equal flash[:error], "Questo docente non appartiene a nessun tuo corso di laurea"
    assert_redirected_to timetables_url
  end

   # ID = 130
    test"User con privilegi tenta di modificare i privilegi di un docente che non appartiene a nessun suo corso di laurea"do
    @user.stubs(:manage_teachers?).returns(true)
    @user.stubs(:manage_capabilities?).returns(true)
    @request.session[:user_id] = :an_id
    t = Teacher.new
    t.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
    Teacher.stubs(:find).returns(t)
     t.user.stubs(:graduate_course_ids).returns([:an_id])
    @user.stubs(:graduate_course_ids).returns([:another_id])
    get  :edit_capabilities, :id=>:an_id
    assert_equal flash[:error], "Questo docente non appartiene a nessun tuo corso di laurea"
    assert_redirected_to timetables_url
    put  :update_capabilities, :id=>:an_id
    assert_equal flash[:error], "Questo docente non appartiene a nessun tuo corso di laurea"
    assert_redirected_to timetables_url
  end

  # ID = 131
  test"User con privilegi utilizza edit_constraints"do
     @request.session[:user_id] = :an_id
     User.stubs(:find).with(:first,:conditions => ["specified_type = 'Teacher' AND specified_id = (?)",:an_id]).returns(@user)
     teacher = Teacher.new
     co = ConstraintsOwner.new
     t = TemporalConstraint.new(:isHard=>0,:startHour=>"9:30",:endHour=>"11:30",:description=>:a_description)
     teacher.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
    Teacher.stubs(:find).returns(teacher)
   ConstraintsOwner.stubs(:find).returns([co])
   TemporalConstraint.stubs(:find).returns(t)
    get :edit_constraints,:id=>:an_id
    assert_template 'edit_constraints'
   end

  # ID = 132
   test"User con privilegi utilizza edit_preferences"do
     @request.session[:user_id] = :an_id
     User.stubs(:find).with(:first,:conditions => ["specified_type = 'Teacher' AND specified_id = (?)",:an_id]).returns(@user)
     teacher = Teacher.new
     co = ConstraintsOwner.new
     t = TemporalConstraint.new(:isHard=>1,:startHour=>"9:30",:endHour=>"11:30",:description=>:a_description)
     teacher.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
    Teacher.stubs(:find).returns(teacher)
   ConstraintsOwner.stubs(:find).returns([co])
   TemporalConstraint.stubs(:find).returns(t)
    get :edit_preferences,:id=>:an_id
    assert_template 'edit_preferences'
   end

  # ID = 133
   test"User con privilegi crea una preferenza valida"do
    @request.session[:user_id] = :an_id
    teacher = Teacher.new
    teacher.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
    Teacher.stubs(:find).with(:an_id).returns(teacher)
    co = ConstraintsOwner.new
    co.stubs(:id=>:an_id,:constraint_id=>:another_id)
    t = TemporalConstraint.new(:id=>:another_id,:description=>"a_description",:isHard=>1,:startHour=>"9:30",:endHour=>"11:30",:day=>2)
   ConstraintsOwner.stubs(:find).returns([co])
   TemporalConstraint.stubs(:find).with(:another_id).returns(t)
   TemporalConstraint.any_instance.stubs(:save).returns(true)
   gc = GraduateCourse.new()
   gc.stubs(:id=>:an_id)
   teacher.user.stubs(:graduate_courses).returns([gc])
   GraduateCourse.stubs(:find).with(:an_id).returns(gc)
   post :create_preference,:id=>:an_id,:start_hour=>"9:30",:end_hour=>"11:30",:day=>1
   assert_template 'teachers/edit_preferences.html.erb'

    ConstraintsOwner.stubs(:find).returns([])
    post :create_preference,:id=>:an_id,:start_hour=>"9:30",:end_hour=>"11:30",:day=>1
   assert_template 'teachers/edit_preferences.html.erb'
  end

  # ID = 134
  test"User con privilegi crea un vincolo valido"do
    @request.session[:user_id] = :an_id
    User.stubs(:find).with(:first,:conditions => ["specified_type = 'Teacher' AND specified_id = (?)",:an_id]).returns(@user)
    teacher = Teacher.new
    teacher.stubs(:id=>:an_id,:name=>"a_name",:surname=>"a_surname")
     t = TemporalConstraint.new(:description=>:a_descrption,:isHard=>0,:startHour=>:a_start_hour,:endHour=>:a_end_hour,:day=>:a_day)
    TemporalConstraint.any_instance.stubs(:save).returns(true)
    Teacher.stubs(:find).with(:an_id).returns(teacher)
    gc = GraduateCourse.new(:id=>:an_id,:duration=>:a_duration)
    teacher.user.stubs(:graduate_courses).returns([gc])
    GraduateCourse.stubs(:find).returns(gc)
    post :create_constraint,:id=>:an_id
   assert_template 'teachers/edit_constraints.html.erb'
  end

  # ID = 135
  test"User con privilegi elimina una preferenza"do
     @request.session[:user_id] = :an_id
    t = TemporalConstraint.new(:description=>:a_description,:isHard=>1,:startHour=>"9:30",:endHour=>"11:30",:day=>1)
   TemporalConstraint.stubs(:find).with(:another_id).returns(t)
    t2 = TemporalConstraint.new(:description=>:a_description,:isHard=>2,:startHour=>"9:30",:endHour=>"11:30",:day=>2)
   TemporalConstraint.stubs(:find).with(:another_one_id).returns(t2)
    co = ConstraintsOwner.new
    co.stubs(:id=>:an_id,:constraint_id=>:another_one_id)
   ConstraintsOwner.stubs(:find).returns([co])
   TemporalConstraint.any_instance.stubs(:save).returns(true)
   Teacher.stubs(:find).with(:an_id).returns(Teacher.new)
   post :destroy_preference,:id=>:an_id,:constraint_id=>:another_id
   assert_template 'edit_preferences'
  end

  # ID = 136
  test"User con privilegi elimina un vincolo"do
    @request.session[:user_id] = :an_id
    User.stubs(:find).with(:first,:conditions => ["specified_type = 'Teacher' AND specified_id = (?)",:an_id]).returns(@user)
    t = TemporalConstraint.new(:description=>:a_descrption,:isHard=>0,:startHour=>:a_start_hour,:endHour=>:a_end_hour,:day=>:a_day)
    TemporalConstraint.stubs(:find).with(:another_id).returns(t)
    Teacher.stubs(:find).with(:an_id).returns(Teacher.new)
    post :destroy_constraint,:id=>:an_id,:constraint_id=>:another_id
    assert_template 'edit_constraints.html.erb'
  end

  # ID = 137
  test "User con privilegi utilizza teacher_preference_priority_up"do
     @request.session[:user_id] = :an_id
     teacher = Teacher.new()
     Teacher.stubs(:find).returns(teacher)
     t = TemporalConstraint.new(:description=>:a_descrption,:isHard=>1,:startHour=>"11:30",:endHour=>"13:30",:day=>1)
     t2 = TemporalConstraint.new(:description=>:a_descrption,:isHard=>2,:startHour=>"12:30",:endHour=>"13:30",:day=>2)
    co = ConstraintsOwner.new
    co.stubs(:id=>:an_id,:constraint_id=>:an_id)
    co2 = ConstraintsOwner.new
    co2.stubs(:id=>:an_id,:constraint_id=>:another_id)
    ConstraintsOwner.stubs(:find).returns([co,co2])
    TemporalConstraint.stubs(:find).with(:an_id).returns(t)
    TemporalConstraint.stubs(:find).with(:another_id).returns(t2)
    TemporalConstraint.any_instance.stubs(:save).returns(true)
    post :teacher_preference_priority_up, :id=>:an_id,:teacher_id=>:an_id,:constraint_id=>:an_id
   assert_template 'edit_preferences.html.erb'

   post :teacher_preference_priority_up, :id=>:an_id,:teacher_id=>:an_id,:constraint_id=>:another_id
   assert_template 'edit_preferences.html.erb'
 end

  # ID = 138
  test "User con privilegi utilizza teacher_preference_priority_down"do
     @request.session[:user_id] = :an_id
     t = TemporalConstraint.new(:description=>:a_descrption,:isHard=>1,:startHour=>"9:30",:endHour=>"11:30",:day=>1)
     t2 = TemporalConstraint.new(:description=>:a_descrption,:isHard => 2, :startHour => "12:30", :endHour => "13:30", :day => 2)
    teacher = Teacher.new()
    Teacher.stubs(:find).returns(teacher)
    co = ConstraintsOwner.new
    co.stubs(:id=>:an_id,:constraint_id=>:an_id)
    co2 = ConstraintsOwner.new
    co2.stubs(:id=>:an_id,:constraint_id=>:another_id)
    ConstraintsOwner.stubs(:find).returns([co,co2])
    TemporalConstraint.stubs(:find).with(:an_id).returns(t)
    TemporalConstraint.stubs(:find).with(:another_id).returns(t2)
    TemporalConstraint.any_instance.stubs(:save).returns(true)
    post :teacher_preference_priority_down, :id=>:an_id,:teacher_id=>:an_id,:constraint_id=>:an_id
   assert_template 'edit_preferences.html.erb'

    post :teacher_preference_priority_down, :id=>:an_id,:teacher_id=>:an_id,:constraint_id=>:another_id
    assert_template 'edit_preferences.html.erb'
 end

 # ID = 139
  test"User con privilegi usa edit"do
    @request.session[:user_id] = :an_id
    Teacher.stubs(:find).returns(Teacher.new)
    u = User.new
    u.stubs(:id=>:an_id, :specified_id=>:another_id)
    User.stubs(:find).returns(u)
    u.stubs(:address).returns(Address.new(:telephone=>''))
    get :edit, :id=>:an_id
  end

 # ID = 140
 test "User con privilegi usa update_personal_data"do
   @request.session[:user_id] = :an_id
    Teacher.stubs(:find).returns(Teacher.new)
    u = User.new
    u.stubs(:id=>:an_id, :specified_id=>:another_id)
    u.stubs(:address).returns(Address.new())
    User.stubs(:find).returns(u)
    u.address.stubs(:save).returns(true)
    post :update_personal_data, :id=>:an_id, :telefono=>"9075393",:prefisso=>"049"
    assert_redirected_to timetables_url
    assert_equal flash[:notice], 'Dati personali aggiornati correttamente'

    u.address.stubs(:save).returns(false)
    post :update_personal_data, :id=>:an_id, :telefono=>"9075393",:prefisso=>"049"
    assert_equal flash[:error], "Errore nell'aggiornamento dei dati personali"
  end

    # ID = 141
  test "User con privilegi elimina un docente"do
   @request.session[:user_id] = :an_id
   u = User.new
   u.stubs(:id=>:an_id, :specified_id=>:another_id)
   User.stubs(:find).returns(u)
   u.stubs(:address).returns(Address.new)
   Teacher.stubs(:find).with(:another_id).returns(Teacher.new)
  delete :destroy, :id=>:an_id
  assert_redirected_to administration_teachers_url
end

  # ID = 142
  test"User che non ha il privilegio di gestione dei docenti utilizza new"do
       @user.stubs(:manage_teachers?).returns(false)
      @request.session[:user_id] = :an_id
      get :new
      assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  # ID = 143
  test"User che non ha il privilegio di gestione dei docenti utilizza create"do
     @user.stubs(:manage_teachers?).returns(false)
     @request.session[:user_id] = :an_id
     post :create
     assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
     assert_redirected_to timetables_url
    end

  # ID = 144
    test"User che non ha il privilegio di gestione dei docenti utilizza administration"do
       @user.stubs(:manage_teachers?).returns(false)
      @request.session[:user_id] = :an_id
      get :administration
      assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  # ID = 145
  test"User che non possiede il privilegio di gestione dei docenti utilizza update_graduate_courses"do
      @user.stubs(:manage_teachers?).returns(false)
      @request.session[:user_id] = :an_id
      put :update_graduate_courses,:id=>:an_id
      assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  # ID = 146
  test"User che non possiede il privilegio di gestire i privilegi utilizza edit_capabilities "do
      @user.stubs(:manage_teachers?).returns(true)
      @user.stubs(:manage_capabilities?).returns(false)
      @request.session[:user_id] = :an_id
      get :edit_capabilities,:id=>:an_id
      assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
end

  # ID = 147
  test"User che non possiede il privilegio di gestire i privilegi utilizza update_capabilities "do
      @user.stubs(:manage_teachers?).returns(true)
      @user.stubs(:manage_capabilities?).returns(false)
      @request.session[:user_id] = :an_id
      put :update_capabilities,:id=>:an_id
      assert_equal flash[:error], "Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
end

# ID = 148
  test"User senza privilegi utilizza edit_constraints"do
    u = User.new
    @request.session[:user_id] = :an_id
    User.stubs(:find).with(:first,:conditions => ["specified_type = 'Teacher' AND specified_id = (?)",:another_id]).returns(u)
    get :edit_constraints,:id=>:another_id
    assert_equal flash[:error], "Non puoi modificare un utente diverso dal tuo"
    assert_redirected_to timetables_url
  end

# ID = 149
  test"User senza privilegi utilizza create_constraint"do
    u = User.new
    @request.session[:user_id] = :an_id
    User.stubs(:find).with(:first,:conditions => ["specified_type = 'Teacher' AND specified_id = (?)",:another_id]).returns(u)
    post :create_constraint,:id=>:another_id
    assert_equal flash[:error], "Non puoi modificare un utente diverso dal tuo"
    assert_redirected_to timetables_url
  end

 # ID = 150
  test"User senza privilegi utilizza destroy_constraint"do
    u = User.new
    @request.session[:user_id] = :an_id
    User.stubs(:find).with(:first,:conditions => ["specified_type = 'Teacher' AND specified_id = (?)",:another_id]).returns(u)
    post :destroy_constraint,:id=>:another_id
    assert_equal flash[:error], "Non puoi modificare un utente diverso dal tuo"
    assert_redirected_to timetables_url
  end

  test"User usa manage_constraints"do
    @request.session[:user_id] = :an_id
    @user.stubs(:manage_teachers?).returns(true)
    t =Teacher.new(:name=>"nome",:surname=>"surname")
    t.stubs(:id).returns(:an_id)
    Teacher.stubs(:find).returns(t)
    c = ConstraintsOwner.new
    c.stubs(:constraint_id).returns(:an_id)
    c2 = ConstraintsOwner.new(:constraint_id=>:another_id)
    c2.stubs(:constraint_id).returns(:another_id)
    ConstraintsOwner.stubs(:find).returns([c,c2])
    t = TemporalConstraint.new(:isHard=>0,:startHour=>"9:30",:endHour=>"11:30")
    TemporalConstraint.stubs(:find).with(:an_id).returns(t)
    TemporalConstraint.stubs(:find).with(:another_id).returns(TemporalConstraint.new(:isHard=>1,:startHour=>"9:30",:endHour=>"11:30"))
    get :manage_constraints, :id=>:an_id
    assert_response :success
    TemporalConstraint.stubs(:find).returns(TemporalConstraint.new(:isHard=>1,:startHour=>"9:30",:endHour=>"11:30"))
    post :destroy_constraint_from_manage_constraints, :id=>:an_id
    assert_redirected_to administration_teachers_url
  end

  test "User usa transform_constraint_in_preference" do
    @request.session[:user_id] = :an_id
    @user.stubs(:manage_teachers?).returns(true)
    t =Teacher.new(:name=>"nome",:surname=>"surname")
    t.stubs(:id).returns(:an_id)
    Teacher.stubs(:find).returns(t)
    c = ConstraintsOwner.new
    c.stubs(:constraint_id).returns(:an_id)
    c2 = ConstraintsOwner.new(:constraint_id=>:another_id)
    c2.stubs(:constraint_id).returns(:another_id)
    ConstraintsOwner.stubs(:find).returns([c,c2])
    t = TemporalConstraint.new(:id=>:an_id,:isHard=>1,:startHour=>"10:30",:endHour=>"11:30")
   TemporalConstraint.stubs(:find).returns(t)
    get :transform_constraint_in_preference, :id=>:an_id,:constraint_id=>:an_id
    assert_redirected_to administration_teachers_url
  end


  private
       def render(a)
         a = "Sigeol"
       end
     end
