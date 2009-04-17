require 'test_helper'

class ClassroomsControllerTest < ActionController::TestCase

  def setup
   @user = stub_everything(:id => :an_id, :mail => :a_mail, :password => :a_password)
   @user.stubs(:active?).returns(true)
   User.stubs(:find).returns(@user)
   @user.stubs(:manage_classrooms?).returns(true)
  end


  test "Guest usa Show " do
    
  end

  test "Guest usa New" do  #Redirect alla pagina di login
    get :new
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa edit" do
     get :edit, :id=>:an_id
     assert_redirected_to new_session_url
  end

  test "Guest usa create" do
      post :create
      assert_redirected_to new_session_url
  end
  
  test "Guest usa update" do
    put :update, :id=>:an_id
    assert_redirected_to new_session_url
  end

   test "Guest usa destroy" do
        delete :destroy, :id=>:an_id
        assert_redirected_to new_session_url
    end
    
  test "Guest usa Administration" do  #Redirect alla pagina di login
    get :administration
    assert_redirected_to new_session_url
    assert_equal "Effettuare il login" , flash[:notice]
  end

  test "Guest usa Remove_classroom_graduate_course" do
     post :remove_classroom_graduate_course, :id=>:an_id
     assert_redirected_to new_session_url
  end
  
  test "Guest usa Add_classroom_graduate_course" do
    post :add_classroom_graduate_course, :id=>:an_id
    assert_redirected_to new_session_url
  end

=begin
  test "User con privilegi utilizza show" do
    @request.session[:user_id] = :an_id
    classroom = stub(:id=>:an_id,:name=>:a_name, :building_id=>:another_id)
    building = stub(:id=>:another_id,:name=>:a_name)
    graduate_course = stub(:id=>:another_id,:name=>:a_name,:duration=>:a_duration)
    Classroom.stubs(:find).with(:an_id).returns(classroom)
    Building.stubs(:find).with(:another_id).returns(building)
    #@user.stubs(:graduate_courses).returns([graduate_course])
    @user.stubs(:graduate_course_ids).returns([graduate_course.id])
    User.anything.stubs(:graduate_course_ids).returns([graduate_course.id])
    get :show, :id=>:an_id
  end
=end
  test "User con privilegi usa new" do
    @request.session[:user_id]=:an_id
    get :new
    assert_response :success
  end

  test"User con privilegi usa edit" do
    @request.session[:user_id]=:an_id
    classroom=Classroom.new()
    classroom.stubs(:id=>:classroom_id)
    Classroom.stubs(:find).with(:classroom_id).returns(classroom)
    stubs_comuni
    get :edit, :id=>:classroom_id
    assert_response :success
  end

    test "User con privilegi crea correttamente una classe(metodo create)" do
        gs = GraduateCourse.new
        @user.stubs(:graduate_courses).returns(gs)
        @request.session[:user_id]=:an_id
        Classroom.any_instance.stubs(:save).returns(true)
        post :create, :classroom=>{:name=>"a_name"}
        assert_equal flash[:notice] ,  'Classroom was successfully created.'
        assert_redirected_to  administration_classrooms_url
    end

    test "User con privilegi crea una classe non valida(metodo create)" do
        @request.session[:user_id]=:an_id
        Classroom.any_instance.stubs(:save).returns(false)
        post :create, :classroom=>{:name=>"another_name"}
        assert_template 'new'
    end

    test "User con privilegi modifica correttamente una classe(metodo update)" do
        @request.session[:user_id]=:an_id
        classroom = Classroom.new
        Classroom.stubs(:find).with(:an_id).returns(classroom)
        classroom.stubs(:update_attributes).returns(true)
        put :update, :id=>:an_id
        assert_equal flash[:notice], 'Classroom was successfully updated.'
        assert_redirected_to administration_classrooms_url
    end

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

    test "User con privilegi usa destroy" do
      @request.session[:user_id]=:an_id
      classroom = Classroom.new()
      classroom.stubs(:id=>:an_id)
      Classroom.stubs(:find).returns(classroom)
      delete :destroy, :id=>:an_id
      assert_redirected_to administration_classrooms_url
    end

    test "User con privilegi usa administration" do
      @request.session[:user_id]=:an_id
       get :administration
       assert_response :success
    end

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
end