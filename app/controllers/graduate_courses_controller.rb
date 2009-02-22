class GraduateCoursesController < ApplicationController
  skip_before_filter :login_required, :only => :index
  before_filter :manage_graduate_courses_required, :only => [:administration, :edit, :update]
  before_filter :didactic_office_required, :only => [:new, :create]
  before_filter :same_graduate_course_required, :only => [:edit, :update, :destroy]
  def index
    @graduate_courses = GraduateCourse.find(:all)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def administration
    ids = @current_user.graduate_course_ids
    @graduate_courses = GraduateCourse.find(ids, :include => :curriculums)
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
    @academic_organization = AcademicOrganization.find(:all)
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /graduate_courses/1/edit
  def edit
    @graduate_course = GraduateCourse.find(params[:id])
    @academic_organization = AcademicOrganization.find(:all)
  end

  def create
    @graduate_course = GraduateCourse.new(params[:graduate_course])
    respond_to do |format|
      if @graduate_course.save
        @graduate_course.users << @current_user
        flash[:notice] = 'Corso di laurea creato correttamente'
        format.html { redirect_to administration_graduate_courses_url }
      else
        @academic_organization = AcademicOrganization.find(:all)
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

  private

  def same_graduate_course_required
    if (!@current_user.graduate_courses.find(params[:id]))
      flash[:error] = "Non puoi modificare questo corso di laurea"
    end
  end
end
