#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: classrooms_controller.rb
#AUTORE:: Carlo Scortegagna
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
# 21/05/2009 Riga 77: Commentata; questo perchè se si re-inizializza la variabile @classroom perdo gli errori associati.
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
  skip_before_filter :login_required, :only => :show
  before_filter :manage_classrooms_required, :except => :show

  # GET /classrooms/1
  def show
    @classroom = Classroom.find(params[:id])
    @building = Building.find(@classroom.building_id)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @classroom.to_xml(:include => :building, :except =>[:created_at, :updated_at]) } # show xml
    end
  end

  # GET /classrooms/new
  def new
    @classroom = Classroom.new
    @buildings = Building.find(:all)

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /classrooms/1/edit
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

  # POST /classrooms
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

  # PUT /classrooms/1
  def update
    @classroom = Classroom.find(params[:id])

    respond_to do |format|
      if @classroom.update_attributes(params[:classroom])
        flash[:notice] = "Aggiornamento dell'aula avvenuto con successo"
        format.html { redirect_to(administration_classrooms_url) }
        format.js{render(:update) {|page| page.redirect_to :action => 'administration'}}
      else
        @buildings = Building.find(:all)
        #@classroom = Classroom.find(params[:id])
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

  # DELETE /classrooms/1
  def destroy
    @classroom = Classroom.find(params[:id])
    @classroom.destroy

    respond_to do |format|
      flash[:notice] = 'Aula eliminata'
      format.html { redirect_to(administration_classrooms_url) }
    end
  end

  def administration
    @classrooms = Classroom.find(:all)
  end

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
        format.html { render :action => "edit" }
        format.js{}
       end
    end

  def edit_constraints
    @classroom = Classroom.find(params[:id])
    classroom_constraint_ids = ConstraintsOwner.find(:all,
      :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Classroom' AND owner_id = (?)", params[:id]], :select => ['constraint_id'])
    @constraints = []
    for id in classroom_constraint_ids do
      @constraints << TemporalConstraint.find(id.constraint_id)
    end
  end

  # creazione e salvataggio nel DB di un nuovo vincolo temporale
  def create_constraint
    if request.post?
      classroom = Classroom.find(params[:id])
      day_nr = from_dayname_to_id(params[:selected_day])
      t = TemporalConstraint.new(:description=>"Vincolo di indisponibilità aula: " + classroom.name,
        :isHard=>0,:startHour=>params[:start_hour],:endHour=>params[:end_hour],:day=>day_nr)
      if t.save
        classroom.constraints << t
        classroom.save
      end

      respond_to do |format|
        @classroom = Classroom.find(params[:id])
        @constraint= t
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

  # action per eliminare un vicolo temporale assegnato all'aula
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

end