class GraduateCoursesController < ApplicationController
  skip_before_filter :login_required, :only => :index
  
  def index
    @graduate_courses = GraduateCourse.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def administration
    @graduate_courses = GraduateCourse.find(:all)
    @curriculums = Curriculum.find(:all)
  end

  def show
    @graduate_course = GraduateCourse.find(params[:id])
    @academic_organization = AcademicOrganization.find(@graduate_course.academic_organization_id)

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def new
    @graduate_course = GraduateCourse.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /graduate_courses/1/edit
  def edit
    @graduate_course = GraduateCourse.find(params[:id])
  end

  def create
    @graduate_course = GraduateCourse.new(params[:graduate_course])

    respond_to do |format|
      if @graduate_course.save
        flash[:notice] = 'GraduateCourse was successfully created.'
        format.html { redirect_to(@graduate_course) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /graduate_courses/1
  def update
    @graduate_course = GraduateCourse.find(params[:id])

    respond_to do |format|
      if @graduate_course.update_attributes(params[:graduate_course])
        flash[:notice] = 'GraduateCourse was successfully updated.'
        format.html { redirect_to(@graduate_course) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /graduate_courses/1
  def destroy
    @graduate_course = GraduateCourse.find(params[:id])
    @graduate_course.destroy

    respond_to do |format|
      format.html { redirect_to :action => 'administration' }
    end
  end
end
