class ClassroomsController < ApplicationController

  #skip_before_filter :login_required, :only => :show
  #se non commento questa, non ho a disposizione @current_user nella show (prendere in considerazione uno sdoppiamento della show, una pubblica e una privata)

  before_filter :manage_classrooms_required, :only => [:new, :create, :edit, :update, :destroy]

  # GET /classrooms/1
  def show
    @classroom = Classroom.find(params[:id])
    @building = Building.find(@classroom.building_id)

    ids = @current_user.graduate_course_ids
    @graduate_courses_associati = GraduateCourse.find(:all, :include => {:classrooms => :graduate_courses},
                               :conditions => ["classrooms_graduate_courses.graduate_course_id IN (?)
                                   AND classrooms_graduate_courses.classroom_id IN (?)", ids, @classroom.id])   

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  # GET /classrooms/new
  def new
    @classroom = Classroom.new
    @buildings = Building.find(:all)

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /classrooms/1/edit
  def edit
    @classroom = Classroom.find(params[:id])
    @buildings = Building.find(:all)
    ids = @current_user.graduate_course_ids
    @graduate_courses = GraduateCourse.find(ids)
    @graduate_courses_associati = GraduateCourse.find(:all, :include => {:classrooms => :graduate_courses},
                               :conditions => ["classrooms_graduate_courses.graduate_course_id IN (?)
                                   AND classrooms_graduate_courses.classroom_id IN (?)", ids, @classroom.id])  
    @graduate_courses_non_associati = @graduate_courses - @graduate_courses_associati
  end

  # POST /classrooms
  def create
    @classroom = Classroom.new(params[:classroom])

    respond_to do |format|
      if @classroom.save
        @classroom.graduate_courses << @current_user.graduate_courses
        flash[:notice] = 'Classroom was successfully created.'
        format.html { redirect_to(administration_classrooms_url) }
      else
        @buildings = Building.find(:all)
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /classrooms/1
  def update
    @classroom = Classroom.find(params[:id])

    respond_to do |format|
      if @classroom.update_attributes(params[:classroom])
        flash[:notice] = 'Classroom was successfully updated.'
        format.html { redirect_to(@classroom) }
      else
        @buildings = Building.find(:all)
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /classrooms/1
  def destroy
    @classroom = Classroom.find(params[:id])
    @classroom.destroy

    respond_to do |format|
      format.html { redirect_to(classrooms_url) }
    end
  end

  def administration
    ids = @current_user.graduate_course_ids
    @classrooms = Classroom.find(:all, :include => {:graduate_courses => :classrooms},
                               :conditions => ["classrooms_graduate_courses.graduate_course_id IN (?)", ids])
    
  end

  def elimina
    if request.post?

      graduate_course_to_remove = GraduateCourse.find(params[:graduate_course_canc])
      classroom_to_modify = graduate_course_to_remove.classrooms.find(params[:classroom_canc])
      if classroom_to_modify
        graduate_course_to_remove.classrooms.delete(classroom_to_modify)
      end

      respond_to do |format|
        @classroom = Classroom.find(params[:id])
        @buildings = Building.find(:all)
        ids = @current_user.graduate_course_ids
        @graduate_courses = GraduateCourse.find(ids)
        @graduate_courses_associati = GraduateCourse.find(:all, :include => {:classrooms => :graduate_courses},
                               :conditions => ["classrooms_graduate_courses.graduate_course_id IN (?)
                                   AND classrooms_graduate_courses.classroom_id IN (?)", ids, @classroom.id])
        @graduate_courses_non_associati = @graduate_courses - @graduate_courses_associati
        format.html { render :action => "edit" }
       end
    end
  end

  def aggiungi
    if request.post?
      classroom_to_modify = Classroom.find(params[:classroom_add])
      graduate_course_to_add = GraduateCourse.find(params[:graduate_course_add])
      classroom_to_modify.graduate_courses << graduate_course_to_add

      respond_to do |format|
        @classroom = Classroom.find(params[:id])
        @buildings = Building.find(:all)
        ids = @current_user.graduate_course_ids
        @graduate_courses = GraduateCourse.find(ids)
        @graduate_courses_associati = GraduateCourse.find(:all, :include => {:classrooms => :graduate_courses},
                               :conditions => ["classrooms_graduate_courses.graduate_course_id IN (?)
                                   AND classrooms_graduate_courses.classroom_id IN (?)", ids, @classroom.id])
        @graduate_courses_non_associati = @graduate_courses - @graduate_courses_associati
        format.html { render :action => "edit" }
       end
    end
  end

end