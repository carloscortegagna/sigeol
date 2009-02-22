class CurriculumsController < ApplicationController
  skip_before_filter :login_required, :only => :index
  before_filter :manage_graduate_courses_required, :only => [:new, :create, :edit, :update, :destroy]
  # GET /curriculums
  # GET /curriculums.xml
  def index
    @curriculums = Curriculum.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @curriculums }
    end
  end

  # GET /curriculums/1
  # GET /curriculums/1.xml
  def show
    @curriculum = Curriculum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @curriculum }
    end
  end

  # GET /curriculums/new
  # GET /curriculums/new.xml
  def new
    @curriculum = Curriculum.new
    @graduate_courses = @current_user.graduate_courses
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @curriculum }
    end
  end

  # GET /curriculums/1/edit
  def edit
    @curriculum = Curriculum.find(params[:id])
    @graduate_courses = @current_user.graduate_courses
  end

  # POST /curriculums
  # POST /curriculums.xml
  def create
    @curriculum = Curriculum.new(params[:curriculum])
    #@curriculum.graduate_course = GraduateCourse.find(params[:graduate_course_id])
    respond_to do |format|
      if @curriculum.save
        flash[:notice] = 'Curriculum creato con successo'
        format.html { redirect_to :controller => 'graduate_courses', :action => 'administration'}
      else
        @graduate_courses = @current_user.graduate_courses
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /curriculums/1
  # PUT /curriculums/1.xml
  def update
    @curriculum = Curriculum.find(params[:id])

    respond_to do |format|
      if @curriculum.update_attributes(params[:curriculum])
        flash[:notice] = 'Curriculum was successfully updated.'
        format.html { redirect_to :controller => 'graduate_courses', :action => 'administration' }
      else
        @graduate_courses = @current_user.graduate_courses
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /curriculums/1
  # DELETE /curriculums/1.xml
  def destroy
    @curriculum = Curriculum.find(params[:id])
    @curriculum.destroy

    respond_to do |format|
      format.html { redirect_to :controller => 'graduate_courses', :action => 'administration' }
    end
  end
end
