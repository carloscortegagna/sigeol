require 'test_helper'

class GraduateCoursesControllerTest < ActionController::TestCase

  def setup
     @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
     @user.stubs(:active?).returns(true)
     User.stubs(:find).returns(@user)
    end

  test "Guest usa index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:graduate_courses)
  end

  test "Guest usa administration" do
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa new" do 
    get :new
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa edit" do
    get :edit, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa create" do
    post :create
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa update" do
     put :update, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa destroy" do
     delete :destroy, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test"User usa show"do
    @request.session[:user_id] = :an_id
    gc = GraduateCourse.new
    gc.stubs(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    ao = AcademicOrganization.new(:id=>:another_id,:name=>:a_name,:number=>:a_number)
    GraduateCourse.stubs(:find).returns(gc)
    AcademicOrganization.stubs(:find).returns(ao)
    get :show, :id=>:an_id
    assert_template 'graduate_courses/show'
  end

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

  test"User con privilegi usa new"do
    @user.stubs(:own_by_didactic_office?).returns(true)
    @request.session[:user_id] = :an_id
    gc = GraduateCourse.new
    gc.stubs(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    get :new
    assert_response :success
    assert_template 'new'
  end

  test"User con privilegi usa edit"do
     @user.stubs(:manage_graduate_courses?).returns(true)
     gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
     GraduateCourse.stubs(:find).with(:an_id).returns(gc)
     @user.graduate_courses.stubs(:find).with(:an_id).returns(gc)
     @request.session[:user_id] = :an_id
     get :edit, :id=>:an_id
     assert_response :success
     assert_template 'edit'
  end

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

  test"User con privilegi crea un corso di laurea non valido"do
    @user.stubs(:own_by_didactic_office?).returns(true)
    @request.session[:user_id] = :an_id
    GraduateCourse.any_instance.stubs(:save).returns(false)
    post :create,:graduate_course=>{:duration=>:a_duration},:unico=>false
    assert_template 'new'
  end

  test"User con privilegi usa metodo update"do
     @user.stubs(:manage_graduate_courses?).returns(true)
     gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
     GraduateCourse.stubs(:find).with(:an_id).returns(gc)
     @user.graduate_courses.stubs(:find).with(:an_id).returns(gc)
     @request.session[:user_id] = :an_id
     gc.stubs(:update_attributes).returns(true)
    put :update,:id=>:an_id
    assert_equal flash[:notice], 'GraduateCourse was successfully updated.'
  end

  test"User con privilegi usa metodo update invalidando il corso laurea"do
     @user.stubs(:manage_graduate_courses?).returns(true)
     gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
     GraduateCourse.stubs(:find).with(:an_id).returns(gc)
     @user.graduate_courses.stubs(:find).with(:an_id).returns(gc)
     @request.session[:user_id] = :an_id
     gc.stubs(:update_attributes).returns(false)
    #put :update,:id=>:an_id
    #assert_redirected_to 'edit'
  end

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

  test"User senza privilegi usa update"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    @user.graduate_courses.stubs(:find).returns(false)
    #put :update, :id=>:another_id
    #assert_equal flash[:error],"Non puoi modificare questo corso di laurea"
  end

  test"User senza privilegi usa edit"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    @user.graduate_courses.stubs(:find).returns(false)
    #get :edit, :id=>:another_id
    #assert_equal flash[:error],"Non puoi modificare questo corso di laurea"
  end

  test"User senza privilegi usa destroy"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    @user.graduate_courses.stubs(:find).returns(false)
    #delete :destroy, :id=>:another_id
    #assert_equal flash[:error],"Non puoi modificare questo corso di laurea"
  end

  #Uno user che non è la segreteria tenta di utilizzare le azioni che devono essere eseguite dopo il filtro didactic_office_required
  test"User senza privilegi usa create"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    get :create
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

  test"User senza privilegi usa new"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    post :new
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

  test"User che non è una segreteria usa destroy"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    delete :destroy, :id=>:an_id
    assert_equal flash[:error],  "Non possiedi i privilegi per effettuare questa operazione"
    assert_redirected_to timetables_url
  end

end

