#=QuiXoft - Progetto SIGEOL
#NOME FILE:: classrooms_controller.rb
#AUTORE:: Carlo Scortegagna
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
# 21/05/2009 Riga 77: Commentata; questo perche' se si re-inizializza la variabile @classroom perdo gli errori associati.
#
# 20/05/2009 Aggiunto sia su create che su update le istruzioni necessarie per renderizzare il contenuto con js:
#  format.js{render(:update) {|page| page.redirect_to :action => 'administration'}}
#
# 22/04/2009 completata la gestione dei vincoli
#
# 03/03/2009 completata l'assegnazione delle aule ai vari corsi di laurea
#  
# 13/02/2009 prima stesura del file


class ClassroomsController < ApplicationController

  # metodi che non devono essere sottoposti al filtro login_required, in quanto di pubblico accesso
  # tutti gli altri metodi non esplicitamente elencati verranno sottoposti al filtro login_required
  skip_before_filter :login_required, :only => :show

  # tutti i metodi sono sottoposti al filtro manage_buildings_required, ad eccezione di quelli elencati nel paramentro :except
  before_filter :manage_classrooms_required, :except => :show
  before_filter :classroom_in_use, :only => [:destroy, :edit_constraints, :destroy_constraints, :create_constraints ]
  # Inizializza le variabili d'istanza @classroom e @building per la vista show.
  def show
    @classroom = Classroom.find(params[:id])
    @building = Building.find(@classroom.building_id)
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @classroom.to_xml(:include => :building, :except =>[:created_at, :updated_at]) } # show xml
    end
  end

  # Crea 1 nuova variabili d'istanza vuota (@classroom) e inizializza la variabile d'istanza @classroom per la vista new.
  def new
    @classroom = Classroom.new
    @buildings = Building.find(:all)
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # Inizializza le variabili d'istanza @classroom, @buildings, @graduate_courses,
  # @graduate_courses_associati e @graduate_courses_non_associati per la vista edit.
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

  # Salva una nuova classroom nel sistema, caratterizzata dai parametri contenuti in params[:classroom].
  # In caso di esito positivo associa l'aula ai graduate_course dell'utente loggato e viene fatto un redirect alla vista administration di classroom.
  # In caso di problemi nel salvataggio, viene riproposta la vista new e vengono segnalati gli eventuali errori.
  def create
    @classroom = Classroom.new(params[:classroom])
    optional = false
    optional = true if params[:lab]
    @classroom.lab = optional
    respond_to do |format|
      if @classroom.save
        @classroom.graduate_courses << @current_user.graduate_courses
        flash[:notice] = "Inserimento della nuova aula avvenuto con successo"
        format.html { redirect_to(administration_classrooms_url) }
        format.js{render(:update) {|page| page.redirect_to :action => 'administration'}}
      else
        @buildings = Building.find(:all)
        format.html { render :action => "new" }
        format.js{}
      end
    end
  end

  # Aggiorna i campi della classroom oggetto di invocazione.
  # In caso di esito positivo viene fatto un redirect alla vista administration di classroom.
  # In caso di problemi nel salvataggio, viene riproposta la vista edit, vengono inizializzate le variabili 
  # necessarie a tale vista e vengono segnalati gli eventuali errori.
  def update
    @classroom = Classroom.find(params[:id])
    respond_to do |format|
      if @classroom.update_attributes(params[:classroom])
        flash[:notice] = "Aggiornamento dell'aula avvenuto con successo"
        format.html { redirect_to(administration_classrooms_url) }
        format.js{render(:update) {|page| page.redirect_to :action => 'administration'}}
      else
        @buildings = Building.find(:all)
        ids = @current_user.graduate_course_ids
        @graduate_courses = GraduateCourse.find(ids)
        @graduate_courses_associati = GraduateCourse.find(:all, :include => {:classrooms => :graduate_courses},
                               :conditions => ["classrooms_graduate_courses.graduate_course_id IN (?)
                                   AND classrooms_graduate_courses.classroom_id IN (?)", ids, @classroom.id])
        @graduate_courses_non_associati = @graduate_courses - @graduate_courses_associati
        format.html { render :action => "edit" }
        format.js{render :action=>"create.js.rjs"}
      end
    end
  end

  # Elimina definitivamente dal DB la classroom oggetto di invocazione.
  # Dopo la distruzione viene fatto un redirect alla vista administration di classroom.
  def destroy
    @classroom = Classroom.find(params[:id])
    @classroom.destroy
    respond_to do |format|
      flash[:notice] = 'Aula eliminata'
      format.html { redirect_to(administration_classrooms_url) }
    end
  end

  # Inizializza la variabile d'istanza @classrooms per la vista administration
  def administration
    @classrooms = Classroom.find(:all)
  end

  # Rimuove l'associazione dalla classroom oggetto di invocazione al graduate_course passato come parametro (params[:graduate_course_canc])
  # nel caso tale classe non fosse più messa a disposizione di quel determinato corso di laurea.
  # Al termine dell'operazione viene fatto un redirect alla vista edit, in cui vengono anche segnalati gli eventuali errori
  def remove_classroom_graduate_course
    if request.post? && params[:graduate_course_canc]
      graduate_course_to_remove = GraduateCourse.find(params[:graduate_course_canc])
      classroom_to_modify = graduate_course_to_remove.classrooms.find(params[:id])
      if classroom_to_modify
        graduate_course_to_remove.classrooms.delete(classroom_to_modify)
      end
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
      format.js{}
    end
  end

  # Crea un associazione tra la classroom oggetto di invocazione e il graduate_course passato come parametro (params[:graduate_course_add])
  # nel caso fosse necessario mettere tale classe a disposizione di quel determinato corso di laurea.
  # Al termine dell'operazione viene fatto un redirect alla vista edit, in cui vengono anche segnalati gli eventuali errori
  def add_classroom_graduate_course
    if request.post? && params[:graduate_course_add]
      classroom_to_modify = Classroom.find(params[:id])
      graduate_course_to_add = GraduateCourse.find(params[:graduate_course_add])
      classroom_to_modify.graduate_courses << graduate_course_to_add
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
        #format.html { render :action => "edit" }
        format.js{}
       end
    end

  # Inizializza le variabili d'istanza @classroom e @constraints per la vista edit_constraints.
  def edit_constraints
    @classroom = Classroom.find(params[:id])
    classroom_constraint_ids = ConstraintsOwner.find(:all,
      :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Classroom' AND owner_id = (?)", params[:id]], :select => ['constraint_id'])
    @constraints = []
    for id in classroom_constraint_ids do
      @constraints << TemporalConstraint.find(id.constraint_id)
    end
  end

  # Crea un nuovo temporal_constraints per la classroom oggetto di invocazione.
  # Al termine dell'operazione viene fatto un redirect alla vista edit_constraints, con la segnalazione degli eventuali errori avvenuti.
  def create_constraint
    if request.post?
      classroom = Classroom.find(params[:id])
      day_nr = from_dayname_to_id(params[:selected_day])
      t = TemporalConstraint.new(:description=>"Vincolo di indisponibilità aula: " + classroom.name,
        :isHard=>0,:startHour=>params[:start_hour],:endHour=>params[:end_hour],:day=>day_nr)
      @constraint = t
      if t.save
        classroom.constraints << t # associo il nuovo vincolo con l'aula
        @error_unique = !t.is_unique_constraint?(classroom)
        #classroom.save
      end

      respond_to do |format|
        @classroom = Classroom.find(params[:id])
        #@constraint= t
        #parte originale.. forse utilizzabile dal clock
        classroom_constraint_ids = ConstraintsOwner.find(:all,
            :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Classroom' AND owner_id = (?)", params[:id]], :select => ['constraint_id'])
        @constraints = []
        for id in classroom_constraint_ids do
          @constraints << TemporalConstraint.find(id.constraint_id)
        end
        format.html { render :action => "edit_constraints" }
        format.js{}
      end
    end
  end

  # Elimina definitivamente dal DB il temporal_constraints passato come paramentro (params[:constraint_id]).
  # Al termine dell'operazione viene fatto un redirect alla vista edit_constraints, con la segnalazione degli eventuali errori avvenuti
  def destroy_constraint
    constraint_to_destroy = TemporalConstraint.find(params[:constraint_id])
    constraint_to_destroy.destroy
    respond_to do |format|
        @constraint = constraint_to_destroy
        #parte originale.. forse utilizzabile dal clock
        @classroom = Classroom.find(params[:id])
        classroom_constraint_ids = ConstraintsOwner.find(:all,
            :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Classroom' AND owner_id = (?)", params[:id]], :select => ['constraint_id'])
        @constraints = []
        for id in classroom_constraint_ids do
          @constraints << TemporalConstraint.find(id.constraint_id)
        end
        format.html { render :action => "edit_constraints" }
        format.js{}
    end
  end

  private

    def classroom_in_use
      classroom = Classroom.find(params[:id])
      graduate_courses = classroom.graduate_courses
      in_use = false
      name = nil
      graduate_courses.each do |g|
        if g.timetables_in_generation?
          in_use = true
          name = g.name
          break
        end
      end
      if in_use
        flash[:error] = "Non è possibile modificare quest'aula in quanto è in uso per la generazione dell'orario per il corso di laurea " +name
        redirect_to administration_classrooms_url
      end
    end
end