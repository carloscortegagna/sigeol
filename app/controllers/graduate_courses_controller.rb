#=QuiXoft - Progetto SIGEOL
#NOME FILE:: graduate_courses_controller.rb
#AUTORE:: Beggiato Andrea
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
# 19/05/2009 sistemate le action index e show per gli utenti non loggati
# 
# 11/05/2009 Nel filtro graduate_course_required aggiunta l'istruzione redirect_to
#
# 11/05/2009 Inizializzata la variabile @academic_organization nell'azione update(caso else)
#
# 18/02/2009 aggiunto l'inserimento di un corso di laurea e dei relativi curriculum


class GraduateCoursesController < ApplicationController
  skip_before_filter :login_required, :only => :index
  before_filter :manage_graduate_courses_required, :only => [:administration, :edit, :update, :destroy]
  before_filter :didactic_office_required, :only => [:new, :create, :destroy]
  before_filter :same_graduate_course_required, :only => [:edit, :update, :destroy]

  # Inizializza la variabile d'istanza @graduate_courses per la vista administration
  def administration
    ids = @current_user.graduate_course_ids
    @graduate_courses = GraduateCourse.find(ids, :include => :curriculums)
  end

  # Inizializza la variabile d'istanza @graduate_course e @academic_organization per la vista show
  def show
    @graduate_course = GraduateCourse.find(params[:id])
    @academic_organization = AcademicOrganization.find(@graduate_course.academic_organization_id)
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @graduate_course.to_xml }
    end
  end

  # Crea 1 nuova variabili d'istanza vuota (@graduate_course) e inizializza la variabile d'istanza @academic_organization per la vista new.
  def new
    @graduate_course = GraduateCourse.new
    @academic_organization = AcademicOrganization.find(:all)
    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # Inizializza le variabili d'istanza @graduate_course e @academic_organization per la vista edit.
  def edit
    @graduate_course = GraduateCourse.find(params[:id])
    @academic_organization = AcademicOrganization.find(:all)
  end

  # Salva un nuovo graduate_course nel sistema, caratterizzata dai parametri contenuti in params[:graduate_course].
  # In caso di esito positivo associa il graduate_course all'utente al momento loggato.
  # - Se params[:unico] e' true si genera automaticamente un unico curriculum per il corso di laurea appena creato
  # - Se params[:unico] e' false viene fatto un redirect alla vista new_curriculum di curriculums, in cui sarà
  #   possibile creare uno o più curricula per il corso di laurea appena creato.
  # In caso di problemi nel salvataggio, viene riproposta la vista new e vengono segnalati gli eventuali errori.
  def create
    @graduate_course = GraduateCourse.new(params[:graduate_course])
    respond_to do |format|
      if @graduate_course.save
        @graduate_course.users << @current_user
        if params[:unico]
          c = Curriculum.new(:name => "Unico")
          c.graduate_course = @graduate_course
          if c.save
            flash[:notice] = 'Corso di laurea creato correttamente'
            format.html { redirect_to administration_graduate_courses_url }
            format.js{render(:update) {|page| page.redirect_to administration_graduate_courses_url}}
          else
            flash[:error] = 'Errore nella creazione del corso di laurea'
            format.html { redirect_to administration_graduate_courses_url }
            format.js{render(:update) {|page| page.redirect_to administration_graduate_courses_url}}
          end
        else
          flash[:notice] = "Inserire un curriculum per il corso di laurea #{@graduate_course.name}"
          format.html { redirect_to new_curriculum_url}
          format.js{render(:update) {|page| page.redirect_to new_curriculum_url}}
        end
      else
        @academic_organization = AcademicOrganization.find(:all)
         format.html { render :action => "new" }
         format.js{}
      end
    end
  end

  # Aggiorna i campi del graduate_course oggetto di invocazione.
  # In caso di esito positivo viene fatto un redirect alla vista administration di classroom.
  # In caso di problemi nel salvataggio, viene riproposta la vista edit, vengono inizializzate le variabili
  # necessarie a tale vista e vengono segnalati gli eventuali errori.
  def update
    @graduate_course = GraduateCourse.find(params[:id])
    respond_to do |format|
      if @graduate_course.update_attributes(params[:graduate_course])
        flash[:notice] = 'Corso di laurea aggiornato con successo'
        format.html { redirect_to administration_graduate_courses_url }
        format.js{render(:update) {|page| page.redirect_to(administration_graduate_courses_url)}}
      else
        @academic_organization = AcademicOrganization.find(:all)
        format.html { render :action => "edit" }
        format.js{}
      end
    end
  end

  # Elimina definitivamente dal DB il graduate_course oggetto di invocazione.
  # Dopo la distruzione viene fatto un redirect alla vista administration di classroom.
  def destroy
    @graduate_course = GraduateCourse.find(params[:id])
    @graduate_course.destroy
    respond_to do |format|
      format.html { redirect_to :action => 'administration' }
    end
  end

  private

  # Controlla che lo User attualmente loggato sia effettivamente colui che ha creato il graduate_course passato come parametro (params[:id]).
  # In caso negativo, viene fatto un redirect all'index di timetables e viene segnalato l'errore.
  def same_graduate_course_required
    if (!@current_user.graduate_courses.find(params[:id]))
      flash[:error] = "Non puoi modificare questo corso di laurea"
      redirect_to timetables_url
    end
  end
  
end