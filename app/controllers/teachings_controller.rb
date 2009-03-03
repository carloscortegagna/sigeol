class TeachingsController < ApplicationController
  skip_before_filter :login_required, :only => [:index ,:show]
  before_filter :manage_teachings_required, :except => [:index, :show]
  before_filter :same_graduate_course_required, :only => [:edit, :update, :destroy,
                                                          :select_teacher, :assign_teacher]

  def index
      @teachings = Teaching.find :all
  end
  # GET /teachings/1
  # GET /teachings/1.xml
  def show
    @teaching = Teaching.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teaching }
    end
  end

  def administration
    @graduate_courses = @current_user.graduate_courses
    @graduate_courses.each do |g|
      g['teachings'] = []
      g.curriculums.each do |c|
        c.teachings.each do |t|
          g['teachings'] << t
        end
      end
      g['teachings'].uniq!
    end
  end
  # GET /teachings/new
  # GET /teachings/new.xml
  def new
    @teaching = Teaching.new
    @graduate_courses = @current_user.graduate_courses
    @year = Period.find(:all, :select => "DISTINCT year")
    @subperiod = Period.find(:all, :select => "DISTINCT subperiod")

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @teaching }
    end
  end

  # GET /teachings/1/edit
  def edit
    @teaching = Teaching.find(params[:id])
  end

  # POST /teachings
  # POST /teachings.xml
  def create
    @teaching = Teaching.new(params[:teaching])
    curriculum = Curriculum.find(params[:curriculum_id])
    optional = false
    optional = true if params[:isOptional]
    period = Period.find_by_subperiod_and_year(params[:subperiod], params[:year])
    if period
      @teaching.period = period
    end
    respond_to do |format|
      if curriculum && @teaching.belongs.build(:curriculum => curriculum, :isOptional => optional) && @teaching.save
        flash[:notice] = 'Insegnamento creato correttamente.'
        format.html { redirect_to select_teacher_teaching_url(@teaching) }
        format.xml  { render :xml => @teaching, :status => :created, :location => @teaching }
      else
        @graduate_courses = @current_user.graduate_courses
        @year = Period.find(:all, :select => "DISTINCT year")
        @subperiod = Period.find(:all, :select => "DISTINCT subperiod")
        format.html { render :action => "new" }
        format.xml  { render :xml => @teaching.errors, :status => :unprocessable_entity }
      end
    end
  end
  def select_teacher
    @teaching = Teaching.find(params[:id])
    ids = @current_user.graduate_course_ids
    @teachers = Teacher.find(:all, :include => {:user => :graduate_courses},
                            :conditions => ["graduate_courses_users.graduate_course_id IN (?) AND teachers.id NOT IN (?)
                                             AND users.password IS NOT NULL",ids, @teaching.teacher_id])
  end
  def assign_teacher
    @teacher = Teacher.find(params[:teacher_id])
    @teaching = Teaching.find(params[:id])
    @teaching.teacher = @teacher
    if @teaching.save
      flash[:notice] = "Docente assegnato con successo"
      redirect_to administration_teachings_url
    else
      redirect_to select_teacher_url(@teaching)
    end
  end
  # PUT /teachings/1
  # PUT /teachings/1.xml
  def update
    @teaching = Teaching.find(params[:id])

    respond_to do |format|
      if @teaching.update_attributes(params[:teaching])
        flash[:notice] = 'Teaching was successfully updated.'
        format.html { redirect_to(@teaching) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @teaching.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /teachings/1
  # DELETE /teachings/1.xml
  def destroy
    @teaching = Teaching.find(params[:id])
    @teaching.destroy

    respond_to do |format|
      format.html { redirect_to(administration_teachings_url) }
      format.xml  { head :ok }
    end
  end

  private

  def same_graduate_course_required
    ids = @current_user.graduate_course_ids
    graduate_course = GraduateCourse.find(:all, :include => {:curriculums => :teachings},
                                          :conditions => ["graduate_courses.id IN (?) AND teachings.id = ?", ids, params[:id]])
    unless graduate_course
      flash[:error] = "Questo insegnamento non appartiane a nessun tuo corso di laurea"
      redirect_to timetables_url
    end
  end
end
