class ClassroomsController < ApplicationController
  skip_before_filter :login_required, :only => :show
  before_filter :manage_classrooms_required, :only => [:new, :create, :edit, :update, :destroy]

  # GET /classrooms/1
  # GET /classrooms/1.xml
  def show
    @classroom = Classroom.find(params[:id])
    @building = Building.find(@classroom.building_id)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classroom }
    end
  end

  # GET /classrooms/new
  # GET /classrooms/new.xml
  def new
    @classroom = Classroom.new
    @buildings = Building.find :all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @classroom }
    end
  end

  # GET /classrooms/1/edit
  def edit
    @classroom = Classroom.find(params[:id])
  end

  # POST /classrooms
  # POST /classrooms.xml
  def create
    @classroom = Classroom.new(params[:classroom])

    respond_to do |format|
      if @classroom.save
        @classroom.graduate_courses = @current_user.graduate_courses #NON TUTTI I CORSI
        flash[:notice] = 'Classroom was successfully created.'
        format.html { redirect_to administration_building_url }
        format.xml  { render :xml => @classroom, :status => :created, :location => @classroom }
      else
        @buildings = Building.find :all
        format.html { render :action => "new" }
        format.xml  { render :xml => @classroom.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classrooms/1
  # PUT /classrooms/1.xml
  def update
    @classroom = Classroom.find(params[:id])

    respond_to do |format|
      if @classroom.update_attributes(params[:classroom])
        flash[:notice] = 'Classroom was successfully updated.'
        format.html { redirect_to(@classroom) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classroom.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classrooms/1
  # DELETE /classrooms/1.xml
  def destroy
    @classroom = Classroom.find(params[:id])
    @classroom.destroy

    respond_to do |format|
      format.html { redirect_to(classrooms_url) }
      format.xml  { head :ok }
    end
  end

  def administration
    ids = @current_user.graduate_course_ids
    @buildings = Building.find(:all, :include => {:classrooms => :graduate_courses},
                               :conditions => ["classrooms_graduate_courses.graduate_course_id IN (?)", ids])
  end
end