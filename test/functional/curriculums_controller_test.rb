require 'test_helper'

class CurriculumsControllerTest < ActionController::TestCase
  include CurriculumsHelper
  #inizializzo uno user
  def setup
   @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
   @user.stubs(:active?).returns(true)
   User.stubs(:find).returns(@user)
  end

  #ID 51
  test "Guest usa show" do
    curriculum=Curriculum.new
    curriculum.stubs(:id=>:an_id,:name=>:a_name)
    Curriculum.stubs(:find).with(:an_id).returns(curriculum)
   end
  
  #ID 52
  test "Guest usa New" do
    get :new
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

  #ID 53
  test "Guest usa edit" do
    get :edit, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

  #ID 54
  test"Guest usa create" do
    post :create, :curriculum=>{:name=>:a_name}
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

  #ID 55
  test"Guest usa update" do
    put :update, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

  #ID 56
  test"Guest usa edit_teachings" do
        get :edit_teachings, :id=>:an_id
      assert_redirected_to new_session_url
      assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

  #ID 57
  test"Guest usa update_teachings"do
    put :update_teachings, :id=>:an_id, :teaching_id=>:another_id
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
 end
  
  #ID 58
  test"Guest usa destroy" do
    delete :destroy, :id=>:an_id
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

  #ID 59
  test "User con privilegi usa new" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    @user.stubs(:graduate_courses).returns([gc])
    get :new
    assert_response :success
  end

  #ID 60
  test "User con privilegi usa edit" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    @user.stubs(:graduate_courses).returns([gc])
    same_graduate_course(c)
    get :edit, :id=>:an_id
    assert_response :success
  end

  #ID 61
  test "User con privilegi crea correttamente un curriculum(metodo create)" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    Curriculum.any_instance.stubs(:save).returns(true)
    post :create, :curriculum=>{:name=>:a_name}
    assert_redirected_to :controller => 'graduate_courses', :action => 'administration'
    assert_equal flash[:notice], 'Curriculum creato con successo'
  end

  #ID 62
  test "User con privilegi crea un curriculum non valido(metodo create)" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    Curriculum.any_instance.stubs(:save).returns(false)
    gc = GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    @user.stubs(:graduate_courses).returns([gc])
    post :create, :curriculum=>{:name=>:a_name}
    assert_template 'new'
  end

  #ID 63
  test "User con privilegi modifica correttamente un curriculum(metodo update)" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c =Curriculum.new(:id=>:an_id,:name=>:a_name)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    c.stubs(:update_attributes).returns(true)
    same_graduate_course(c)
    put :update, :id=>:an_id
    assert_redirected_to  :controller => 'graduate_courses', :action => 'administration'
    assert_equal flash[:notice],  'Curriculum modificato con successo'
  end

  #ID 64
  test "User con privilegi modifica un curriculum e lo rendo non valido(metodo update)" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c =Curriculum.new(:id=>:an_id,:name=>:a_name)
    g = GraduateCourse.new(:id=>:another_id, :name=>:a_name,:duration=>:a_duration)
    @user.stubs(:graduate_courses).returns([g])
    Curriculum.stubs(:find).with(:an_id).returns(c)
    c.stubs(:update_attributes).returns(false)
    same_graduate_course(c)
    put :update, :id=>:an_id
    assert_template 'edit'
  end

  #ID 65
  test "User con privilegi usa edit_teachings" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    gc =GraduateCourse.new(:id=>:an_id,:name=>:a_name,:duration=>:a_duration)
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    same_graduate_course(c)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    c.graduate_course = gc
    get :edit_teachings, :id=>:an_id
    assert_response :success
  end

  #ID 66
  test "User con privilegi usa update_teachings attraverso il metodo http put" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    t = Teaching.new(:id=>:another_id, :name=>:another_name)
    same_graduate_course(c)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    Teaching.stubs(:find).with(:another_id).returns(t)
    c.belongs.stubs(:create).returns(true)
    put :update_teachings, :id=>:an_id, :teaching_id=>:another_id
    assert_equal flash[:notice],  "Insegnamento aggiunto correttamente"
    assert_redirected_to administration_graduate_courses_url
  end

  #ID 67
  test"User con privilegi usa update_teachings attraverso il metodo http delete." do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    t = Teaching.new(:id=>:another_id, :name=>:another_name)
    same_graduate_course(c)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    c.teachings.stubs(:find).with(:another_id).returns(t)
    delete :update_teachings, :id=>:an_id, :t_to_remove=>:another_id
    assert_equal flash[:notice], "Insegnamento eliminato con successo"
    assert_redirected_to administration_graduate_courses_url
  end

  #ID 68
  test"User con privilegi usa update_teachings attraverso il metodo http delete Tenta di eliminare un insegnamento non presente" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    t = Teaching.new(:id=>:another_id, :name=>:another_name)
    same_graduate_course(c)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    c.teachings.stubs(:find).with(:another_id).returns(nil)
    delete :update_teachings, :id=>:an_id, :t_to_remove=>:another_id
    assert_equal flash[:error], "Insegnamento non presente nel curriculum"
    assert_redirected_to administration_graduate_courses_url
  end

  #ID 69
  test"User con privilegi usa destroy" do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    Curriculum.stubs(:find).with(:an_id).returns(c)
   delete :destroy, :id=>:an_id
   assert_redirected_to  :controller => 'graduate_courses', :action => 'administration'
  end

  #ID 70
  test"User usa il metodo edit su un curriculum che non appartiene a nessun suo corso di laurea"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    show_curriculum(Curriculum.new)
    show_curriculum_admin(Classroom.new)
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    c.stubs(:graduate_course_id).returns(:an_id)
    @user.stubs(:graduate_course_ids).returns([:another_id])
    get :edit, :id=>:an_id
    assert_equal flash[:error], "Questo curriculum non appartiene a nessun tuo corso di laurea"
  end

  #ID 71
  test"User usa il metodo update su un curriculum che non appartiene a nessun suo corso di laurea"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    c.stubs(:graduate_course_id).returns(:an_id)
    @user.stubs(:graduate_course_ids).returns([:another_id])
    put :update, :id=>:an_id
    assert_equal flash[:error], "Questo curriculum non appartiene a nessun tuo corso di laurea"
  end

#ID 72
  test"User usa il metodo edit_teachings su un curriculum che non appartiene a nessun suo corso di laurea"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    c.stubs(:graduate_course_id).returns(:an_id)
    @user.stubs(:graduate_course_ids).returns([:another_id])
    get :edit_teachings, :id=>:an_id
    assert_equal flash[:error], "Questo curriculum non appartiene a nessun tuo corso di laurea"
  end
  
  #ID 73
  test"User usa il metodo update_teachings su un curriculum che non appartiene a nessun suo corso di laurea"do
    @user.stubs(:manage_graduate_courses?).returns(true)
    @request.session[:user_id] = :an_id
    c = Curriculum.new(:id=>:an_id,:name=>:a_name)
    Curriculum.stubs(:find).with(:an_id).returns(c)
    c.stubs(:graduate_course_id).returns(:an_id)
    @user.stubs(:graduate_course_ids).returns([:another_id])
    put :update_teachings, :id=>:an_id
    assert_equal flash[:error], "Questo curriculum non appartiene a nessun tuo corso di laurea"
  end

  #ID 74
  test"User che non possiede il privilegio di modificare i corsi di laurea usa new"do
      @user.stubs(:manage_graduate_courses?).returns(false)
      @request.session[:user_id] = :an_id
      get :new
      assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  #ID 75
  test"User che non possiede il privilegio di modificare i corsi di laurea usa create"do
      @user.stubs(:manage_graduate_courses?).returns(false)
      @request.session[:user_id] = :an_id
      post :new
      assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  #ID 76
  test"User che non possiede il privilegio di modificare i corsi di laurea usa edit"do
      @user.stubs(:manage_graduate_courses?).returns(false)
      @request.session[:user_id] = :an_id
      get :edit,:id=>:an_id
      assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  #ID 77
  test"User che non possiede il privilegio di modificare i corsi di laurea usa update"do
      @user.stubs(:manage_graduate_courses?).returns(false)
      @request.session[:user_id] = :an_id
      put :edit,:id=>:an_id
      assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  #ID 78
  test"User che non possiede il privilegio di modificare i corsi di laurea usa destroy"do
      @user.stubs(:manage_graduate_courses?).returns(false)
      @request.session[:user_id] = :an_id
      delete :destroy,:id=>:an_id
      assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  #ID 79
  test"User che non possiede il privilegio di modificare i corsi di laurea usa edit_teachings"do
      @user.stubs(:manage_graduate_courses?).returns(false)
      @request.session[:user_id] = :an_id
      get :edit_teachings,:id=>:an_id
      assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  #ID 80
  test"User che non possiede il privilegio di modificare i corsi di laurea usa update_teachings"do
      @user.stubs(:manage_graduate_courses?).returns(false)
      @request.session[:user_id] = :an_id
      put :update_teachings,:id=>:an_id
      assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
      assert_redirected_to timetables_url
    end

  private
  def same_graduate_course(c)
    @user.stubs(:graduate_course_ids).returns([:an_id])
    c.stubs(:graduate_course_id).returns(:an_id)
  end
  
  def render(a)
         a = "Sigeol"
       end
end