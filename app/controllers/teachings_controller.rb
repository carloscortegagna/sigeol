#=QuiXoft - Progetto SIGEOL
#NOME FILE:: teachings.controller.rb
#AUTORE:: Scortegagna Carlo
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
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

  # Inizializza le variabili d'istanza @teachings e @graduate_courses per la vista index.
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

  # Inizializza le variabili d'istanza @teaching e @teacher per la vista show.
  def show
    notfound = false
    @teaching = Teaching.find(params[:id]) rescue notfound = true
    unless notfound
      @teacher = nil
      if @teaching.teacher_id != nil
        @teacher = Teacher.find(@teaching.teacher_id)
      end
    end
    respond_to do |format|
      format.html {
          if notfound
            redirect_to :controller => 'timetables', :action => 'not_found'
          end
          }
      format.xml  {
          if notfound
            redirect_to :controller => 'timetables', :action => 'not_found'
          else
            render :xml => @teaching.to_xml(:except =>[:created_at, :updated_at, :id, :period_id, :teacher_id])
          end
      }
    end
  end

  # Inizializza la variabile d'istanza @graduate_courses per la vista administration.
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
  
  # Crea 1 nuova variabili d'istanza vuota (@teaching) e inizializza le variabili d'istanza @graduate_courses,
  # @year e @subperiod per la vista new.
  def new
    @teaching = Teaching.new
    @graduate_courses = @current_user.graduate_courses
    @year = Period.find(:all, :select => "DISTINCT year")
    @subperiod = Period.find(:all, :select => "DISTINCT subperiod")
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # Inizializza le variabili d'istanza @teaching, @period, @year e @subperiod per la vista edit.
  def edit
    notfound = false
    @teaching = Teaching.find(params[:id]) rescue notfound = true
    unless notfound
      @period = @teaching.period
      @year = Period.find(:all, :select => "DISTINCT year", :conditions=> ["year !=  #{@period.year} "])
      @subperiod = Period.find(:all, :select => "DISTINCT subperiod",:conditions=> ["subperiod !=  #{@period.subperiod}"])
    end
    respond_to do |format|
      format.html {
          if notfound
            redirect_to :controller => 'timetables', :action => 'not_found'
          end
          }
    end
  end

  # Salva un nuovo teaching nel sistema, caratterizzata dai parametri contenuti in params[:teaching].
  # In caso di esito positivo viene fatto un redirect alla vista select_teacher per permettere la scelta di un teacher
  # da associare all'insegnamento appena creato.
  # In caso di problemi nel salvataggio, viene riproposta la vista new e vengono segnalati gli eventuali errori.
  def create
    @teaching = Teaching.new(params[:teaching])
    if params[:curriculum_id]
     curriculum = Curriculum.find(params[:curriculum_id])
    end
    optional = false
    optional = true if params[:isOptional]
    period = Period.find_by_subperiod_and_year(params[:subperiod], params[:year])
    if period
      @teaching.period = period
    end
    respond_to do |format|
      @teaching.save
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

  # Inizializza le variabili d'istanza @teaching e @teachers per la vista select_teacher.
  # Se al teaching oggetto della chiamata era gia' associato un teacher, quest'ultimo viene disassociato per permettere
  # la scelta di un nuovo docente.
  def select_teacher
    @teaching = Teaching.find(params[:id])
    ids = @current_user.graduate_course_ids
    @teachers = Teacher.find(:all, :include => {:user => :graduate_courses},
                            :conditions => ["graduate_courses.id IN (?) AND users.password IS NOT NULL",ids])
    @teachers.delete(@teaching.teacher)
  end

  # Assegna il teacher passato come parametro (params[:teacher_id]) al teaching oggetto della chiamata (params[:id])
  # Se l'operazione va a buon fine viene fatto un redirect alla vista administration, altrimenti viene nuovamente proposta la vista select_teacher
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
  
  # Aggiorna i campi del teaching oggetto di invocazione.
  # In caso di esito positivo viene fatto un redirect alla vista administration di cteachings.
  # In caso di problemi nel salvataggio, viene riproposta la vista edit, vengono inizializzate le variabili
  # necessarie a tale vista e vengono segnalati gli eventuali errori.
  def update
    @teaching = Teaching.find(params[:id])
    @period = @teaching.period
    period = Period.find_by_subperiod_and_year(params[:subperiod], params[:year])
    if period
      @teaching.period = period
    end
    respond_to do |format|
      if @teaching.update_attributes(params[:teaching])
        flash[:notice] = 'Insegnamento aggiornato con successo'
        format.html { redirect_to administration_teachings_url }
        format.js{render(:update) {|page| page.redirect_to(administration_teachings_url)}}
      else
        @graduate_courses = @current_user.graduate_courses
        @year = Period.find(:all, :select => "DISTINCT year")
        @subperiod = Period.find(:all, :select => "DISTINCT subperiod")
        format.html { render :action => "edit" }
        format.js{render :action => 'create.js.rjs'}
      end
    end
  end

  # Effettua la cancellazione definitiva dal DB del teaching passato come parametro (params[:id]).
  def destroy
    @teaching = Teaching.find(params[:id])
    @teaching.destroy
    respond_to do |format|
      format.html { redirect_to(administration_teachings_url) }
    end
  end

  private

  # Controlla che lo User attualmente loggato possa effettivamente gestire il teaching passato come parametro (params[:id]).
  # In caso negativo, viene fatto un redirect all'index di timetables e viene segnalato l'errore.
  def same_graduate_course_required
    ids = @current_user.graduate_course_ids
    graduate_course = GraduateCourse.find(:all, :include => {:curriculums => :teachings},
                                          :conditions => ["graduate_courses.id IN (?) AND teachings.id = ?", ids, params[:id]])
    unless graduate_course.size != 0
      flash[:error] = "Questo insegnamento non appartiene a nessun tuo corso di laurea"
      redirect_to timetables_url
    end
  end
end
