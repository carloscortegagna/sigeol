class GraduateCoursesController < ApplicationController
  # GET /graduate_courses
  # GET /graduate_courses.xml
  def index
    @graduate_courses = GraduateCourse.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @graduate_courses }
    end
  end

  # GET /graduate_courses/1
  # GET /graduate_courses/1.xml
  def show
    @graduate_course = GraduateCourse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @graduate_course }
    end
  end

  # GET /graduate_courses/new
  # GET /graduate_courses/new.xml
  def new
    @graduate_course = GraduateCourse.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @graduate_course }
    end
  end

  # GET /graduate_courses/1/edit
  def edit
    @graduate_course = GraduateCourse.find(params[:id])
  end

  # POST /graduate_courses
  # POST /graduate_courses.xml
  def create
    @graduate_course = GraduateCourse.new(params[:graduate_course])

    respond_to do |format|
      if @graduate_course.save
        flash[:notice] = 'GraduateCourse was successfully created.'
        format.html { redirect_to(@graduate_course) }
        format.xml  { render :xml => @graduate_course, :status => :created, :location => @graduate_course }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @graduate_course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /graduate_courses/1
  # PUT /graduate_courses/1.xml
  def update
    @graduate_course = GraduateCourse.find(params[:id])

    respond_to do |format|
      if @graduate_course.update_attributes(params[:graduate_course])
        flash[:notice] = 'GraduateCourse was successfully updated.'
        format.html { redirect_to(@graduate_course) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @graduate_course.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /graduate_courses/1
  # DELETE /graduate_courses/1.xml
  def destroy
    @graduate_course = GraduateCourse.find(params[:id])
    @graduate_course.destroy

    respond_to do |format|
      format.html { redirect_to(graduate_courses_url) }
      format.xml  { head :ok }
    end
  end
end
