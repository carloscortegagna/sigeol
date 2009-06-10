#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: classrooms_controller_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'
class ClassroomsControllerTest < ActionController::TestCase
 include ClassroomsHelper
  #inizializzo uno user
  def setup
   @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
   @user.stubs(:active?).returns(true)
   User.stubs(:find).returns(@user)
   show_classroom(Classroom.new)
   menu_admin
   show_classroom_admin(Classroom.new)
   @user.stubs(:manage_classrooms?).returns(true)
  end

# ID = 21
  test "Guest usa show " do
    c = Classroom.new(:id=>:an_id,:name=>:a_name)
    b = Building.new
    b.stubs(:id=>:an_id,:name=>:a_name)
    Classroom.stubs(:find).with(:an_id).returns(c)
    Building.stubs(:find).returns(b)
    get :show, :id=>:an_id
    
  end

# ID = 22
  test "Guest usa new" do  #Redirect alla pagina di login
    get :new
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 23
  test "Guest usa edit" do
     get :edit, :id=>:an_id
     assert_redirected_to new_session_url
  end

 # ID = 24
  test "Guest usa create" do
      post :create
      assert_redirected_to new_session_url
  end

 # ID = 25
  test "Guest usa update" do
    put :update, :id=>:an_id
    assert_redirected_to new_session_url
  end

# ID = 26
  test "Guest usa destroy" do
        delete :destroy, :id=>:an_id
        assert_redirected_to new_session_url
    end

 # ID = 27
  test "Guest usa Administration" do  #Redirect alla pagina di login
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Si prega di effettuare il login" , flash[:notice]
  end

 # ID = 28
  test "Guest usa Remove_classroom_graduate_course" do
     post :remove_classroom_graduate_course, :id=>:an_id
     assert_redirected_to new_session_url
  end

  # ID = 29
  test "Guest usa Add_classroom_graduate_course" do
    post :add_classroom_graduate_course, :id=>:an_id
    assert_redirected_to new_session_url
  end

  # ID = 30
  test"Guest usa edit_constraints"do
    get :edit_constraints,:id=>:an_id
    assert_redirected_to new_session_url
  end

 # ID = 31
  test"Guest usa create_constraint"do
    post :create_constraint,:id=>:an_id
    assert_redirected_to new_session_url
  end

 # ID = 32
  test"Guest usa destroy_constraint"do
    get :destroy_constraint,:id=>:an_id
    assert_redirected_to new_session_url
  end

  # ID = 33
  test "User con privilegi usa new" do
    @request.session[:user_id]=:an_id
    get :new
    assert_response :success
  end

  # ID = 34
  test"User con privilegi usa edit" do
    @request.session[:user_id]=:an_id
    classroom=Classroom.new()
    classroom.stubs(:id=>:classroom_id)
    Classroom.stubs(:find).with(:classroom_id).returns(classroom)
    stubs_comuni
    get :edit, :id=>:classroom_id
    assert_response :success
  end

  # ID = 35
    test "User con privilegi crea correttamente una classe(metodo create)" do
        gs = GraduateCourse.new
        @user.stubs(:graduate_courses).returns(gs)
        @request.session[:user_id]=:an_id
        Classroom.any_instance.stubs(:save).returns(true)
        post :create, :classroom=>{:name=>"a_name"}
        assert_equal flash[:notice] ,  'Inserimento della nuova aula avvenuto con successo'
        assert_redirected_to  administration_classrooms_url
    end

  # ID = 36
    test "User con privilegi crea una classe non valida(metodo create)" do
        @request.session[:user_id]=:an_id
        Classroom.any_instance.stubs(:save).returns(false)
        post :create, :classroom=>{:name=>"another_name"}
        assert_template 'new'
    end

  # ID = 37
    test "User con privilegi modifica correttamente una classe(metodo update)" do
        @request.session[:user_id]=:an_id
        classroom = Classroom.new
        Classroom.stubs(:find).with(:an_id).returns(classroom)
        classroom.stubs(:update_attributes).returns(true)
        put :update, :id=>:an_id
        assert_equal flash[:notice], 'Aggiornamento dell\'aula avvenuto con successo'
        assert_redirected_to administration_classrooms_url
    end

  # ID = 38
    test "User con privilegi modifica una classe esistente e la rende non valida" do
      @request.session[:user_id]=:an_id
      classroom = Classroom.new
      classroom.stubs(:id=>:classroom_id)
      Classroom.stubs(:find).with(:classroom_id).returns(classroom)
      classroom.stubs(:update_attributes).returns(false)
      stubs_comuni
      put :update, :id=>:classroom_id
      assert_template 'edit'
    end

  # ID = 39
    test "User con privilegi usa destroy" do
      @request.session[:user_id]=:an_id
      classroom = Classroom.new()
      classroom.stubs(:id=>:an_id)
      Classroom.stubs(:find).returns(classroom)
      delete :destroy, :id=>:an_id
      assert_redirected_to administration_classrooms_url
    end

  # ID = 40
    test "User con privilegi usa administration" do
      @request.session[:user_id]=:an_id
       get :administration
       assert_response :success
    end

  # ID = 41
    test "User con privilegi usa remove_classroom_graduate_course" do
        @request.session[:user_id]=:an_id
        graduate_course_to_remove = GraduateCourse.new
        graduate_course_to_remove.stubs(:id=>:another_id)
        classroom_to_modify = Classroom.new
        classroom_to_modify.stubs(:id=>:classroom_id)
        GraduateCourse.stubs(:find).with(:another_id).returns(graduate_course_to_remove)
        Classroom.stubs(:find).with(:classroom_id).returns(classroom_to_modify)
        graduate_course_to_remove.classrooms.stubs(:find).returns(classroom_to_modify)
        stubs_comuni
        post :remove_classroom_graduate_course, :id=>:classroom_id, :graduate_course_canc=>:another_id
    end

  # ID = 42
    test "User con privilegi usa add_classroom_graduate_course" do
       @request.session[:user_id]=:an_id
        graduate_course_to_add = GraduateCourse.new
        graduate_course_to_add.stubs(:id=>:another_id)
        classroom_to_modify = Classroom.new
        classroom_to_modify.stubs(:id=>:classroom_id)
        Classroom.stubs(:find).with(:classroom_id).returns(classroom_to_modify)
        GraduateCourse.stubs(:find).with(:another_id).returns(graduate_course_to_add)
        stubs_comuni
       post :add_classroom_graduate_course, :id=>:classroom_id, :graduate_course_add=>:another_id
      end

  # ID = 43
  test"User con privilegi usa  edit_constraints"do
    @request.session[:user_id]=:an_id
    t = TemporalConstraint.new(:id=>:an_id,:startHour=>"19:30",:endHour=>"20:30",:day=>:a_day)
    c = Classroom.new(:id=>:an_id,:name=>:a_name)
    Classroom.stubs(:find).with(:an_id).returns(c)
    co = ConstraintsOwner.new
    ConstraintsOwner.stubs(:find).returns([co])
    TemporalConstraint.stubs(:find).returns(t)
    get :edit_constraints, :id=>:an_id
    assert_response :success
  end

  # ID = 44
  test"User con privilegi usa create_constraints"do
    @request.session[:user_id] = :an_id
    c = Classroom.new(:id=>:an_id,:name=>"a_name")
    t = TemporalConstraint.new(:id=>:an_id,:startHour=>"19:30",:endHour=>"20:30",:day=>1)
    Classroom.stubs(:find).with(:an_id).returns(c)
    c.stubs(:constraints).returns([t])
    Classroom.any_instance.stubs(:save).returns(true)
    co = ConstraintsOwner.new
    ConstraintsOwner.stubs(:find).returns([co])
    TemporalConstraint.stubs(:find).returns(t)
    TemporalConstraint.any_instance.stubs(:save).returns(true)
    post :create_constraint, :id=>:an_id, :start_hour=>"9:30",:end_hour=>"11:30",:selected_day=>"lunedi"
   assert_template 'edit_constraints.html.erb'
  end

  # ID = 45
  test"User con privilegi usa destroy_constraint"do
    @request.session[:user_id] = :an_id
    c = Classroom.new(:id=>:an_id,:name=>:a_name)
    t = TemporalConstraint.new(:id=>:an_id,:startHour=>"19:30",:endHour=>"20:30",:day=>:a_day)
    Classroom.stubs(:find).with(:an_id).returns(c)
    TemporalConstraint.stubs(:find).returns(t)
     co = ConstraintsOwner.new
    ConstraintsOwner.stubs(:find).returns([co])
    post :destroy_constraint, :id=>:an_id, :constraint_id=>:another_id
    assert_template 'edit_constraints.html.erb'
  end

  # ID = 46
  test"User senza privilegi usa administration"do
     @request.session[:user_id] = :an_id
     @user.stubs(:manage_classrooms?).returns(false)
     get :administration
     assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
     assert_redirected_to timetables_url
   end

  # ID = 47
  test"User senza privilegi usa new"do
     @request.session[:user_id] = :an_id
     @user.stubs(:manage_classrooms?).returns(false)
     get :new
     assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
     assert_redirected_to timetables_url
   end

 # ID = 48
  test"User senza privilegi usa edit"do
     @request.session[:user_id] = :an_id
     @user.stubs(:manage_classrooms?).returns(false)
     get :edit,:id=>:an_id
     assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
     assert_redirected_to timetables_url
   end

 # ID = 49
  test"User senza privilegi usa create"do
     @request.session[:user_id] = :an_id
     @user.stubs(:manage_classrooms?).returns(false)
     post :create,:id=>:an_id
     assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
     assert_redirected_to timetables_url
   end

  # ID = 50
  test"User senza privilegi usa update"do
     @request.session[:user_id] = :an_id
     @user.stubs(:manage_classrooms?).returns(false)
     put :update,:id=>:an_id
     assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
     assert_redirected_to timetables_url
   end

 # ID = 51
  test"User senza privilegi usa destroy"do
     @request.session[:user_id] = :an_id
     @user.stubs(:manage_classrooms?).returns(false)
     delete :destroy,:id=>:an_id
     assert_equal flash[:error],"Non possiedi i privilegi per effettuare questa operazione"
     assert_redirected_to timetables_url
   end

  private
       def stubs_comuni 
        b = Building.new
        b.stubs(:id=>:another_id,:name=>:a_name)
        Building.stubs(:find).with(:all).returns([b])
        gs = GraduateCourse.new
        gs.stubs(:id => :another_id, :name => :another_name)
        @user.stubs(:graduate_course_ids).returns([:another_id])
        GraduateCourse.stubs(:find).with([:another_id]).returns([gs])
        GraduateCourse.stubs(:find).with(:all, :include => {:classrooms => :graduate_courses},
                               :conditions => ["classrooms_graduate_courses.graduate_course_id IN (?)
                                   AND classrooms_graduate_courses.classroom_id IN (?)",[:another_id], :classroom_id]).returns([gs])
       end
       private
       def render(a)
         a = "Sigeol"
       end
     end