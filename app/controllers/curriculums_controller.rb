#=QuiXoft - Progetto SIGEOL
#NOME FILE:: curriculums_controller.rb
#AUTORE:: Carlo Scortegagna
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
# 14/05/2009 completate le viste xml
#
# 02/03/2009 eliminate le azioni inutilizzate
#
# 13/02/2009 prima stesura del file

class CurriculumsController < ApplicationController

  # metodi che non devono essere sottoposti al filtro login_required, in quanto di pubblico accesso
  # tutti gli altri metodi non esplicitamente elencati verranno sottoposti al filtro login_required
  skip_before_filter :login_required, :only => :show

  # i metodi elencati nel paramentro :only sono sottoposti al filtro manage_graduate_courses_required
  before_filter :manage_graduate_courses_required, :only => [:new, :create, :edit, :update, :destroy,
                                                             :edit_teachings, :update_teachings]

  # i metodi elencati nel paramentro :only sono sottoposti al filtro same_graduate_course_required
  before_filter :same_graduate_course_required, :only => [:edit, :update, :edit_teachings, :update_teachings]

  # Crea 1 nuova variabili d'istanza vuota (@@curriculum) e inizializza la variabile d'istanza @graduate_courses per la vista new.
  def new
    @curriculum = Curriculum.new
    graduate_course = GraduateCourse.find_by_name((flash[:notice]).from(46))
    @graduate_courses = @current_user.graduate_courses - [graduate_course]
    @graduate_courses = [graduate_course]+@graduate_courses
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # Inizializza le variabili d'istanza @curriculum e @graduate_courses per la vista edit.
  def edit
    @curriculum = Curriculum.find(params[:id])
    @graduate_courses = @current_user.graduate_courses
  end

  # Salva un nuovo curriculum nel sistema, caratterizzato dai paramentri contenuti in params[:curriculum].
  # In caso di esito positivo viene fatto un redirect alla vista administration di graduate_courses.
  # In caso di problemi nel salvataggio, viene riproposta la vista new e vengono segnalati gli eventuali errori.
  def create
    @curriculum = Curriculum.new(params[:curriculum])
    respond_to do |format|
      if @curriculum.save
        flash[:notice] = 'Curriculum creato con successo'
        format.html { redirect_to :controller => 'graduate_courses', :action => 'administration'}
        format.js{render(:update) {|page| page.redirect_to :controller => 'graduate_courses', :action => 'administration'}}
      else
        @graduate_courses = @current_user.graduate_courses
        format.html { render :action => "new" }
        format.js{}
        end
    end
  end

  # Aggiorna i campi del curriculum oggetto di invocazione.
  # In caso di esito positivo viene fatto un redirect alla vista administration di graduate_courses.
  # In caso di problemi nel salvataggio, viene riproposta la vista edit e vengono segnalati gli eventuali errori.
  def update
    @curriculum = Curriculum.find(params[:id])
    respond_to do |format|
      if @curriculum.update_attributes(params[:curriculum])
        flash[:notice] = 'Curriculum modificato con successo'
        format.html { redirect_to :controller => 'graduate_courses', :action => 'administration' }
        format.js{render(:update) {|page| page.redirect_to :controller => 'graduate_courses', :action => 'administration'}}
      else
        @graduate_courses = @current_user.graduate_courses
        format.html { render :action => "edit" }
        format.js{ render :action => "create.js.rjs" }
      end
    end
  end

  # Inizializza le variabili d'istanza @curriculum e @teachings per la vista edit_teachings.
  def edit_teachings
    @curriculum = Curriculum.find(params[:id])
    id = @curriculum.graduate_course.id
    @teachings = Teaching.find(:all, :include => {:curriculums => :graduate_course},
                                  :conditions => ["graduate_courses.id = ?", id])
    @teachings = @teachings - @curriculum.teachings
  end

  # Gestisce le assegnazioni dei teachings al curriculum passato come parametro (params[:id]).
  # Vengono gestiti distintamente 2 casi:
  # - Se la chiamata al metodo e' di tipo put, viene assegnato l'insegnamento identificato dal parametro params[:teaching_id] al curriculum in oggetto.
  # - Se invece la chiamata e' di tipo delete, viene eliminata l'associazione tra il curriculum in oggetto e l'insegnamento identificato dal parametro params[:teaching_id].
  # Al termine di entrambi i casi viene fatto un redirect alla vista administration di graduate_courses.
  def update_teachings
    if request.put?
      @curriculum = Curriculum.find(params[:id])
      teaching = Teaching.find params[:teaching_id]
      optional = false
      optional = true if params[:isOptional]
      @curriculum.belongs.create(:teaching => teaching, :isOptional => optional)
      flash[:notice] = "Insegnamento aggiunto correttamente"
      redirect_to administration_graduate_courses_url
    end
    if request.delete?
      @curriculum = Curriculum.find(params[:id])
      teaching = @curriculum.teachings.find(params[:t_to_remove])
      if (teaching)
        @curriculum.teachings.delete(teaching)
        flash[:notice] = "Insegnamento eliminato con successo"
      else
        flash[:error] = "Insegnamento non presente nel curriculum"
      end
      redirect_to administration_graduate_courses_url
    end
  end

  # Elimina definitivamente dal DB il curriculum oggetto di invocazione.
  # Dopo la distruzione viene fatto un redirect alla vista administration di graduate_courses.
  def destroy
    @curriculum = Curriculum.find(params[:id])
    @curriculum.destroy
    respond_to do |format|
      format.html { redirect_to :controller => 'graduate_courses', :action => 'administration' }
    end
  end

  private

  # Controlla che lo User attualmente loggato sia effettivamente colui che ha creato il curriculum passato come parametro (params[:id]).
  # In caso negativo, viene fatto un redirect all'index di timetables e viene segnalato l'errore.
  def same_graduate_course_required
    ids = @current_user.graduate_course_ids
    curriculum = Curriculum.find(params[:id])
    unless (ids.include?(curriculum.graduate_course_id))
      flash[:error] = "Questo curriculum non appartiene a nessun tuo corso di laurea"
      redirect_to timetables_url
    end
  end
  
end