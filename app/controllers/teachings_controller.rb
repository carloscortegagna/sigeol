# QuiXoft - Progetto ”SIGEOL”
# NOME FILE: teachings.controller.rb
# AUTORE: Scortegagna Carlo
# DATA CREAZIONE: 13/02/2009
#
# REGISTRO DELLE MODIFICHE:
# 
# 14/05/2009 finite le viste xml
#
# 14/03/2009 aggiunta l'assegnazione dei docenti agli insegnamenti e l'assegnazione degli insegnamenti ai curriculum
#
# 24/02/2009 aggiunta la gestione dei curriculum
# 
# 16/02/2009 action "index" resa pubblica. Creata una nuova action "administration", accessibile solamente dagli utenti loggati

class TeachingsController < ApplicationController
  skip_before_filter :login_required, :only => [:index ,:show]
  before_filter :manage_teachings_required, :except => [:index, :show]
  before_filter :same_graduate_course_required, :only => [:edit, :update, :destroy,
                                                          :select_teacher, :assign_teacher]

  def index
    @teachings = Teaching.find(:all)
    @graduate_courses = GraduateCourse.find(:all, :include => :curriculums)
    @graduate_courses.each do |g|
      g['teachings'] = []
      g.curriculums.each do |c|
        c.teachings.each do |t|
          g['teachings'] << t
        end
      end
      g['teachings'].uniq!
    end
    respond_to do |format|
      format.html
      format.xml  { render :xml => @teachings.to_xml(:except =>[:created_at, :updated_at])}
    end
  end

  # GET /teachings/1
  # GET /teachings/1.xml
  def show
    @teaching = Teaching.find(params[:id])
    @teacher = nil
    if @teaching.teacher_id != nil
      @teacher = Teacher.find(@teaching.teacher_id)
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teaching.to_xml(:except =>[:created_at, :updated_at, :id, :period_id, :teacher_id]) }
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
        format.js{render(:update) {|page| page.redirect_to select_teacher_teaching_url(@teaching)}}
      else
        @graduate_courses = @current_user.graduate_courses
        @year = Period.find(:all, :select => "DISTINCT year")
        @subperiod = Period.find(:all, :select => "DISTINCT subperiod")
        format.html { render :action => "new" }
        format.js{}
      end
    end
  end

  def select_teacher
    @teaching = Teaching.find(params[:id])
    ids = @current_user.graduate_course_ids
    @teachers = Teacher.find(:all, :include => {:user => :graduate_courses},
                            :conditions => ["graduate_courses.id IN (?) AND users.password IS NOT NULL",ids])
    @teachers.delete(@teaching.teacher)
  end

  def assign_teacher
    @teacher = Teacher.find(params[:teacher_id])
    @teaching = Teaching.find(params[:id])
    @teaching.teacher = @teacher
    if @teaching.save
      flash[:notice] = "Docente assegnato con successo"
      redirect_to administration_teachings_url
    else
      redirect_to select_teacher_teaching_url(@teaching)
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
        format.js{render(:update) {|page| page.redirect_to(@teaching)}}
      else
        format.html { render :action => "edit" }
        format.js{render :action => 'create.js.rjs'}
      end
    end
  end

  # cancellazione di un insegnamento
  def destroy
    @teaching = Teaching.find(params[:id])
    @teaching.destroy

    respond_to do |format|
      format.html { redirect_to(administration_teachings_url) }
    end
  end

  private

  def same_graduate_course_required
    ids = @current_user.graduate_course_ids
    graduate_course = GraduateCourse.find(:all, :include => {:curriculums => :teachings},
                                          :conditions => ["graduate_courses.id IN (?) AND teachings.id = ?", ids, params[:id]])
    unless graduate_course.size != 0
      flash[:error] = "Questo insegnamento non appartiane a nessun tuo corso di laurea"
      redirect_to timetables_url
    end
  end
end
