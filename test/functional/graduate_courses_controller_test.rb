require 'test_helper'

class GraduateCoursesControllerTest < ActionController::TestCase
 include GraduateCoursesHelper
  def setup
     @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
     @user.stubs(:active?).returns(true)
     User.stubs(:find).returns(@user)
    end

 # ID = 81
  test "Guest usa administration" do
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 82
  test "Guest usa new" do 
    get :new
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 83
  test "Guest usa edit" do
    get :edit, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 84
  test "Guest usa create" do
    post :create
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 85
  test "Guest usa update" do
     put :update, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 86
  test "Guest usa destroy" do
     delete :destroy, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 87
  test"User usa show"do
    @request.session[:user_id] = :an_id
    gc = GraduateCourse.new
    gc.stubs(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    show_graduate_course(GraduateCourse.new)
    ao = AcademicOrganization.new(:id=>:another_id,:name=>:a_name,:number=>:a_number)
    GraduateCourse.stubs(:find).returns(gc)
    AcademicOrganization.stubs(:find).returns(ao)
    get :show, :id=>:an_id
    assert_template 'graduate_courses/show'
  end

 # ID = 88
  test"User con privilegi usa administration"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    gc = GraduateCourse.new
    gc.stubs(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
   GraduateCourse.stubs(:find).returns([gc])
    get :administration
    assert_response :success
    assert_template 'administration'
  end

 # ID = 89
  test"User con privilegi usa new"do
    @user.stubs(:own_by_didactic_office?).returns(true)
    @request.session[:user_id] = :an_id
    gc = GraduateCourse.new
    menu_admin
    gc.stubs(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    get :new
    assert_response :success
    assert_template 'new'
  end

 # ID = 90
  test"User con privilegi usa edit"do
     @user.stubs(:manage_graduate_courses?).returns(true)
     gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
     GraduateCourse.stubs(:find).with(:an_id).returns(gc)
     show_graduate_course_admin(GraduateCourse.new)
     @user.graduate_courses.stubs(:find).with(:an_id).returns(gc)
     @request.session[:user_id] = :an_id
     get :edit, :id=>:an_id
     assert_response :success
     assert_template 'edit'
  end

 # ID = 91
  test"User con privilegi crea correttamente un corso di laurea unico(metodo create)"do
    @user.stubs(:own_by_didactic_office?).returns(true)
    @request.session[:user_id] = :an_id
    gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.any_instance.stubs(:save).returns(true)
    GraduateCourse.any_instance.stubs(:users).returns([@user])
    Curriculum.any_instance.stubs(:save).returns(true)
    post :create,:graduate_course=>{:name=>:a_name,:duration=>:a_duration},:unico=>true
    assert_equal flash[:notice], 'Corso di laurea creato correttamente'
    assert_redirected_to administration_graduate_courses_url
  end

 # ID = 92
  test"User con privilegi crea un corso di laurea unico non valido(metodo create)"do
    @user.stubs(:own_by_didactic_office?).returns(true)
    @request.session[:user_id] = :an_id
    gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.any_instance.stubs(:save).returns(true)
    GraduateCourse.any_instance.stubs(:users).returns([@user])
    Curriculum.any_instance.stubs(:save).returns(false)
    post :create,:graduate_course=>{:name=>:a_name,:duration=>:a_duration},:unico=>true
    assert_equal flash[:error], 'Errore nella creazione del corso di laurea'
    assert_redirected_to administration_graduate_courses_url
  end

 # ID = 93
  test"User con privilegi crea correttamente un corso di laurea con curricula(metodo create)"do
    @user.stubs(:own_by_didactic_office?).returns(true)
    @request.session[:user_id] = :an_id
    gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    GraduateCourse.any_instance.stubs(:users).returns([@user])
    GraduateCourse.any_instance.stubs(:save).returns(true)
    post :create,:graduate_course=>{:name=>:a_name,:duration=>:a_duration},:unico=>false
    assert_equal flash[:notice], 'Inserire un curriculum per il corso di laurea a_name'
    assert_redirected_to new_curriculum_url
  end

 # ID = 94
  test"User con privilegi crea un corso di laurea non valido"do
    @user.stubs(:own_by_didactic_office?).returns(true)
    @request.session[:user_id] = :an_id
    GraduateCourse.any_instance.stubs(:save).returns(false)
    post :create,:graduate_course=>{:duration=>:a_duration},:unico=>false
    assert_template 'new'
  end

  # ID = 95
  test"User con privilegi usa metodo update"do
     @user.stubs(:manage_graduate_courses?).returns(true)
     gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
     GraduateCourse.stubs(:find).with(:an_id).returns(gc)
     @user.graduate_courses.stubs(:find).with(:an_id).returns(gc)
     @request.session[:user_id] = :an_id
     gc.stubs(:update_attributes).returns(true)
    put :update,:id=>:an_id
    assert_equal flash[:notice], 'Corso di laurea aggiornato con successo'
  end

 # ID = 96
  test"User con privilegi usa metodo update invalidando il corso laurea"do
     @user.stubs(:manage_graduate_courses?).returns(true)
     gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
     GraduateCourse.stubs(:find).with(:an_id).returns(gc)
     @user.graduate_courses.stubs(:find).with(:an_id).returns(gc)
     @request.session[:user_id] = :an_id
     gc.stubs(:update_attributes).returns(false)
    put :update,:id=>:an_id
    assert_template 'edit'
  end

 # ID = 97
  test"User con privilegi usa destroy"do
    @user.stubs(:manage_graduate_courses?).returns(true)
     gc = GraduateCourse.new
     gc.stubs(:id=>:an_id,:name=>:a_name)
     GraduateCourse.stubs(:find).with(:an_id).returns(gc)
    @user.graduate_courses.stubs(:find).with(:an_id).returns(gc)
    @user.stubs(:own_by_didactic_office?).returns(true)
    @request.session[:user_id] = :an_id
    delete :destroy, :id=>:an_id
    assert_redirected_to :action=>'administration'
  end
  
  #test su metodi che necessitano di same_graduate_course_required, utilizzando uno user senza questo privilegio

 # ID = 98
  test"User senza privilegi usa update"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    @user.graduate_courses.stubs(:find).returns(false)
    put :update, :id=>:another_id
    assert_equal flash[:error],"Non puoi modificare questo corso di laurea"
  end

# ID = 99
 test"User senza privilegi usa edit"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    @user.graduate_courses.stubs(:find).returns(false)
    get :edit, :id=>:another_id
    assert_equal flash[:error],"Non puoi modificare questo corso di laurea"
  end

 # ID = 100
  test"User senza privilegi usa destroy"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    @user.graduate_courses.stubs(:find).returns(false)
    @user.stubs(:own_by_didactic_office?).returns(true)
    delete :destroy, :id=>:another_id
    assert_equal flash[:error],"Non puoi modificare questo corso di laurea"
  end

 # ID = 101
  test"User senza privilegi usa create"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    get :create
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

 # ID = 102
  test"User senza privilegi usa new"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    post :new
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

 # ID = 103
  test"User che non è una segreteria usa destroy"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    delete :destroy, :id=>:an_id
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

 # ID = 104
  test"User che non ha il privilegio di modificare i corsi di laurea usa administration"do
    @user.stubs(:manage_graduate_courses?).returns(false)
    @request.session[:user_id] = :an_id
    get :administration
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

 # ID = 105
  test"User che non ha il privilegio di modificare i corsi di laurea usa edit"do
    @user.stubs(:manage_graduate_courses?).returns(false)
    @request.session[:user_id] = :an_id
    get :edit, :id=>:an_id
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

 # ID = 106
  test"User che non ha il privilegio di modificare i corsi di laurea usa update"do
    @user.stubs(:manage_graduate_courses?).returns(false)
    @request.session[:user_id] = :an_id
    put :update, :id=>:an_id
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

  # ID = 107
   test"User che non ha il privilegio di modificare i corsi di laurea usa destroy"do
    @user.stubs(:manage_graduate_courses?).returns(false)
    @request.session[:user_id] = :an_id
    delete :destroy, :id=>:an_id
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

  private
       def render(a)
         a = "Sigeol"
       end

     end

