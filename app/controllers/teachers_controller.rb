# QuiXoft - Progetto ”SIGEOL”
# NOME FILE: teachers.controller.rb
# AUTORE: Scortegagna Carlo
# DATA CREAZIONE: 17/02/2009
#
# REGISTRO DELLE MODIFICHE:
# 
# 19/05/2009 sistemate le action index e show per gli utenti non loggati
#
# 12/05/2009 sia su proprity_down che su priority_up assegnato a i = constraint_to_move_down.isHard.
# Usato i come indice per accedere ai valori degli array e non più constraint_to_move_down.isHard(riga 292 e 323)
# 
# 12/05/2009 per gli array è stato sostituito count con size
#
# 27/04/2009 Completata la gestione delle preferenze
#
# 21/04/2009 Aggiunta la gestione dei vincoli
#
# 14/03/2009 Sistemata l'assegnazione dei docenti agli insegnamenti
#
# 29/02/2009 Aggiunta l'azione administration
#
# 17/02/2009 Aggiunto l'invito dei docenti da parte di chi ha i permessi per farlo


class TeachersController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :show, :pre_activate, :activate]
  before_filter :manage_teachers_required, :only => [:new, :create, :administration, :edit_graduate_courses,
                                                     :update_graduate_courses]
  before_filter :manage_capabilities_required, :only => [:edit_capabilities, :update_capabilities]
  before_filter :same_graduate_course_required, :only => [:edit_graduate_courses, :update_graduate_courses,
                                                          :edit_capabilities, :update_capabilities]
  before_filter :same_teacher_required, :only => [:edit, :update_personal_data, :edit_constraints, :edit_preferences,
                                                          :create_constraint, :destroy_constraint]

  def index
    @teachers = []
    if(Teacher.find(:all).size != 0)
     @teachers = (Teacher.find(:all, :conditions => ['name != "" AND surname != ""'], :order => "surname ASC"))
    end
    respond_to do |format|
      format.html
      format.xml { render :xml => @teachers.to_xml(:except =>[:created_at, :updated_at]) }
    end
  end

  def show
    @teacher = Teacher.find(params[:id])
    @user = User.find(:first, :include => :address,
            :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", params[:id]])
    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @teacher.to_xml(:include => :user, :except =>[:created_at, :updated_at, :digest, :password, :random]) }
    end
  end

  def edit_graduate_courses
    #total_graduate_courses = @current_user.graduate_courses
    total_graduate_courses = GraduateCourse.find(:all)
    @teacher = Teacher.find(params[:id])
    teacher_graduate_courses = @teacher.user.graduate_courses
    @manageable_graduate_courses = total_graduate_courses & teacher_graduate_courses
    @selectable_graduate_courses = total_graduate_courses - teacher_graduate_courses
  end

  def edit_capabilities
    #total_capabilities = @current_user.capabilities
    total_capabilities = Capability.find(:all)
    @teacher = Teacher.find(params[:id])
    teacher_capabilities = @teacher.user.capabilities
    @manageable_capabilities = total_capabilities & teacher_capabilities
    @selectable_capabilities = total_capabilities - teacher_capabilities
  end

  def update_graduate_courses
    @teacher = Teacher.find(params[:id])
    @graduate_course = GraduateCourse.find(params[:ids])
    if request.delete?
      @teacher.user.graduate_courses.delete( @graduate_course)
      if @teacher.user.graduate_courses.size == 0
         @teacher.teachings.delete_all
      end
    end
    if request.put?
      @teacher.user.graduate_courses << (@graduate_course)
    end
    respond_to do |format|
        format.html { edit_graduate_courses
                      render :action => "edit_graduate_courses"
        }
        #flash[:notice] = "Corsi di laurea per il docente #{@teacher.surname} #{@teacher.name} aggiornati con successo"
        #redirect_to administration_teachers_url
        format.js {edit_graduate_courses}
    end
  end

  def update_capabilities
    @teacher = Teacher.find(params[:id])
    @capability = Capability.find(params[:ids])
    if request.delete?
      @teacher.user.capabilities.delete(@capability)
    end
    if request.put?
      @teacher.user.capabilities << (@capability)
    end
      respond_to do |format|
        format.html { edit_capabilities
                      render :action => "edit_capabilities"
        }             
          #flash[:notice] = "Privilegi per il docente #{@teacher.surname} #{@teacher.name} aggiornati con successo"
          #redirect_to administration_teachers_url
        format.js {edit_capabilities}
      end
  end

  def new
    @teacher = User.new()
    @graduate_courses = @current_user.graduate_courses
  end

  def create
    user = User.find_by_mail(params[:mail])
    respond_to do |format|
     if user == nil
      @teacher = User.new()
      @teacher.mail = params[:mail]
      @teacher.random = rand(120)
      t = Teacher.new()
      a = Address.new()
      t.save
      a.save false
      @teacher.specified = t
      @teacher.address = a
        if @teacher.save
        @teacher.graduate_courses << GraduateCourse.find(params[:graduate_course_id])
        flash[:notice] = "Docente invitato con successo"
        TeacherMailer.deliver_activate_teacher(@current_user, @teacher)
        format.html{redirect_to new_teacher_url}
        format.js{render(:update) {|page| page.redirect_to new_teacher_url}}
      else
        @graduate_courses = @current_user.graduate_courses
        format.html{render :action => :new}
        format.js{}
        end
      else
        if user.own_by_teacher?
          user.graduate_courses << GraduateCourse.find(params[:graduate_course_id])
          flash[:notice] = "Docente invitato con successo"
          format.html{redirect_to new_teacher_url}
          format.js{render(:update) {|page| page.redirect_to new_teacher_url}}
        else
          flash[:error] = "La mail inserita è già presente e non corrisponde ad un docente"
          format.html{redirect_to new_teacher_url}
          format.js{render(:update) {|page| page.redirect_to new_teacher_url}}
        end
      end
    end
  end

  def destroy
    @user = User.find(:first, :include => :address,
            :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", params[:id]])
    @teacher = Teacher.find(@user.specified_id)
    @teacher.destroy
    @user.address.destroy
    @user.destroy
    redirect_to(administration_teachers_url)
  end

  def edit
    teacher = Teacher.find(params[:id])
    @user = User.find(:first, :include => :address,
            :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", teacher.id])
  end

  def update_personal_data
    teacher = Teacher.find(params[:id])
    @user = User.find(:first, :include => :address,
            :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", teacher.id])
    @user.address.city = params[:city]
    @user.address.street = params[:street]
    @user.address.telephone= ""
    if(params[:prefisso] != "" || params[:telefono] != "")
      @user.address.telephone = params[:prefisso]+"-"+params[:telefono]
    end
    respond_to do |format|
    if @user.address.save
      flash[:notice] = 'Dati personali aggiornati correttamente'
      format.html{redirect_to(timetables_url)}
      format.js{render(:update) {|page| page.redirect_to timetables_url}}
    else
      flash[:error] = "Errore nell'aggiornamento dei dati personali"
      format.html{render :action=>'edit'}
      format.js{}
    end 
  end
end

  def pre_activate
    @user = User.find params[:id]
    unless @user != nil && @user.specified_type == "Teacher" && !@user.active? && @user.digest == params[:digest]
      flash[:notice] = "Questo docente è già attivo o non esiste"
      redirect_to timetables_url
    end
  end

  def activate
    @user = User.find params[:id]
    respond_to do |format|
      if @user != nil && @user.specified_type == "Teacher" && !@user.active? && @user.digest == params[:digest]
        @user.address.telephone= ""
        if(params[:prefisso] != "" || params[:telefono] != "")
          @user.address.telephone = params[:prefisso]+"-"+params[:telefono]
         end
      if @user.specified.update_attributes(params[:teacher]) && @user.address.update_attributes(params[:address])
            @user.password = params[:user][:password]
           if @user.save
              flash[:notice] = "Account attivato correttamente"
               format.html{redirect_to timetables_url}
               format.js{render(:update) {|page| page.redirect_to timetables_url}}
             else
              format.html{render :action => :pre_activate, :digest => @user.digest}
              format.js{}
            end
        else
          format.html{render :action => :pre_activate, :digest => @user.digest}
          format.js{}
        end
    else
      flash[:error] = "L'utente non esiste od è già attivo"
      redirect_to timetables_url
    end
  end
  end

  def administration
    @teachers = Teacher.find(:all, :conditions => ['name != "" AND surname != ""'], :order => "surname ASC")
    ids = @current_user.graduate_course_ids
    @graduate_courses = GraduateCourse.find(:all, :include => :users,
                :conditions => ["specified_type = 'Teacher' AND users.password is NOT null AND graduate_courses.id IN (?)",ids])
    @not_active_users = User.find(:all, :include => :graduate_courses,
                :conditions => ["users.password IS null AND graduate_courses.id IN (?)",ids])
  end
  
  def edit_constraints
    @teacher = Teacher.find(params[:id])
    teacher_constraint_ids = ConstraintsOwner.find(:all,
      :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Teacher' AND owner_id = (?)", params[:id]],
      :select => ['constraint_id'], :group => 'constraint_id')
    @constraints = []
    for id in teacher_constraint_ids do
      if TemporalConstraint.find(id.constraint_id).isHard == 0
        @constraints << TemporalConstraint.find(id.constraint_id)
      end
    end  
  end

  def create_constraint
    if request.post?
      day_nr = from_dayname_to_id(params[:day])
      t = TemporalConstraint.new(:description=>params[:description],
        :isHard=>0,:startHour=>params[:start_hour],:endHour=>params[:end_hour],:day=>day_nr)
      teacher = Teacher.find(params[:id])
      teacher_graduate_courses = teacher.user.graduate_courses
      if t.save
        for c in teacher_graduate_courses #devo creare un record in constraint_owner per ogni graduate_course del teacher
          co=ConstraintsOwner.new
          co.constraint=t
          co.graduate_course=GraduateCourse.find(c.id)
          co.owner = teacher
          co.save
        end
        #flash[:notice] = "Vincolo inserito con successo"
      #else
      #  flash[:error] = "Errore: vincolo non salvato"
      end
      respond_to do |format|
        @teacher = teacher
        @constraint = t
        format.html { edit_constraints 
                      render :action => "edit_constraints"
        }
        format.js{}
      end
    end
  end

  def destroy_constraint
    constraint_to_destroy = TemporalConstraint.find(params[:constraint_id])
    #if
    constraint_to_destroy.destroy
    #  flash[:notice] = "Vincolo eliminato con successo"
    #else
    #  flash[:error] = "Errore: vincolo non eliminato"
    #end
    respond_to do |format|
      @constraint = constraint_to_destroy
      #necessario per controllo `size` su js
      format.html { edit_constraints
                    render :action => "edit_constraints"
      }
      format.js { edit_constraints }
    end
  end

  def edit_preferences
    @teacher = Teacher.find(params[:id])
    teacher_constraint_ids = ConstraintsOwner.find(:all,
      :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Teacher' AND owner_id = (?)", params[:id]],
      :select => ['constraint_id'], :group => 'constraint_id')
    @constraints = []
    for id in teacher_constraint_ids do
      if TemporalConstraint.find(id.constraint_id).isHard != 0
        @constraints << TemporalConstraint.find(id.constraint_id)
      end
    end
    @constraints = @constraints.sort_by { |c| c[:isHard] }
  end

  def create_preference
    if request.post?
      teacher = Teacher.find(params[:id])
      day_nr = from_dayname_to_id(params[:day])
      teacher_constraint_ids = ConstraintsOwner.find(:all,
          :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Teacher' AND owner_id = (?)", params[:id]],
          :select => ['constraint_id'], :group => 'constraint_id')
      constraints = []
      for id in teacher_constraint_ids do
        if TemporalConstraint.find(id.constraint_id).isHard != 0
         constraints << TemporalConstraint.find(id.constraint_id)
        end
      end
      if constraints.empty?
        preference_value = 1
      else
        preference_value = constraints.size + 1 #conto il numero delle preferenze nel db e metto la giusta priorità a quella nuova
      end
      t = TemporalConstraint.new(:description=>"Preferenza docente: " + teacher.name + " " + teacher.surname,
        :isHard=>preference_value,:startHour=>params[:start_hour],:endHour=>params[:end_hour],:day=>day_nr)
      teacher_graduate_courses = teacher.user.graduate_courses
      if t.save
        for c in teacher_graduate_courses #devo creare un record in constraint_owner per ogni graduate_course del teacher
          co=ConstraintsOwner.new
          co.constraint=t
          co.graduate_course=GraduateCourse.find(c.id)
          co.owner = teacher
          co.save
        end
        #flash[:notice] = "Preferenza inserita con successo"
      #else
        #flash[:error] = "Errore: preferenza non salvata"
      end
      respond_to do |format|
        @teacher = teacher
        @constraint = t
        format.html { edit_preferences
                      render :action => "edit_preferences"
        }
        format.js{ edit_preferences }
      end
    end
  end

  def destroy_preference
    constraint_to_destroy = TemporalConstraint.find(params[:constraint_id])
    if constraint_to_destroy.destroy #eliminando una preferenza vanno aggiornate le priorità delle altre preferenze
      teacher_constraint_ids = ConstraintsOwner.find(:all,
          :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Teacher' AND owner_id = (?)", 
            params[:teacher_id]], :group => 'constraint_id')
      constraints = []
      for tc in teacher_constraint_ids do
        if TemporalConstraint.find(tc.constraint_id).isHard != 0
         constraints << TemporalConstraint.find(tc.constraint_id)
        end
      end
      constraints = constraints.sort_by { |c| c[:isHard] }
      i = 1
      for c in constraints do
        c.isHard = i
        c.save
        i = i + 1
      end
      #flash[:notice] = "Preferenza eliminata con successo"
    #else
      #flash[:error] = "Errore: preferenza non eliminata"
    end
    respond_to do |format|
      @constraint = constraint_to_destroy
      format.html { edit_preferences
                    render :action => "edit_preferences"
      }
      format.js{ edit_preferences }
      end
  end

  def teacher_preference_priority_up
    constraint_to_move_up = TemporalConstraint.find(params[:constraint_id]) #preferenza di cui cambiare la priorità
    if constraint_to_move_up.isHard == 1 #la preferenza è la prima, non devo cambiare niente
      #flash[:notice] = "La preferenza ha già priorità massima"
      already_up = true #tiz: non ho trovato altra soluzione per non modifcare il codice
    else
      already_up = false #tiz: non ho trovato altra soluzione per non modifcare il codice
      teacher_constraint_ids = ConstraintsOwner.find(:all,
          :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Teacher' AND owner_id = (?)",
          params[:teacher_id]], :group => 'constraint_id')
      constraints = []
      for tc in teacher_constraint_ids do
        if TemporalConstraint.find(tc.constraint_id).isHard != 0
         constraints << TemporalConstraint.find(tc.constraint_id)
        end
      end
      i =  constraint_to_move_up.isHard
      constraints = constraints.sort_by { |c| c[:isHard] } #lista ordinata per priorità crescente delle preferenze
      c1 = constraints[i-1] #c1 è la preferenza di cui devo aumentare la priorità
      c1.isHard = i-1 #imposto il nuovo valore di priorità
      c2 = constraints[i-2] #c2 è la preferenze di cui devo diminuire la priorità, perchè il suo posto è stato preso da c1
      c2.isHard = i #imposto la nuova priorità, il nuovo valore equivale al vecchio + 1
      

      c1.save
      c2.save
      #if c1.save && c2.save
        #flash[:notice] = "Priorità della preferenza modificata con successo"
      #else
        #flash[:error] = "Errore nel cambio di preferenza"
      #end
    end
    respond_to do |format|
      @constraint_up = c1
      @constraint_down = c2
      @already_up = already_up
      @teacher = Teacher.find(params[:teacher_id])
      format.html { edit_preferences
                    render :action => "edit_preferences"
      }
      format.js{}
    end
  end

  def teacher_preference_priority_down
    constraint_to_move_down = TemporalConstraint.find(params[:constraint_id]) #preferenza di cui cambiare la priorità
    teacher_constraint_ids = ConstraintsOwner.find(:all,
          :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Teacher' AND owner_id = (?)",
          params[:teacher_id]], :group => 'constraint_id')
    constraints = []
    for tc in teacher_constraint_ids do
      if TemporalConstraint.find(tc.constraint_id).isHard != 0
         constraints << TemporalConstraint.find(tc.constraint_id)
      end
    end
    constraints = constraints.sort_by { |c| c[:isHard] }
    max_priority = constraints.size
    if constraint_to_move_down.isHard == max_priority #la preferenza è l'ultima, non devo fare niente
      #flash[:notice] = "La preferenza ha già priorità minima"
      already_down = true
    else
      already_down = false
      i = constraint_to_move_down.isHard
      c1 = constraints[i-1] #c1 è la preferenza di cui devo diminuire la priorità
      c1.isHard = (constraint_to_move_down.isHard)+1 #imposto il nuovo valore di priorità
      c2 = constraints[i] #c2 è la preferenze di cui devo diminuire la priorità, perchè il suo posto è stato preso da c1
      c2.isHard = (constraint_to_move_down.isHard) #imposto la nuova priorità, il nuovo valore equivale al vecchio + 1
      
      c1.save
      c2.save
      #if c1.save && c2.save
      #  flash[:notice] = "Priorità della preferenza modificata con successo"
      #else
      #  flash[:error] = "Errore nel cambio di preferenza"
      #end
    end
    respond_to do |format|
      @constraint_up = c2
      @constraint_down = c1
      @already_down = already_down
      @teacher = Teacher.find(params[:teacher_id])
      format.html { edit_preferences
                    render :action => "edit_preferences"
      }
      format.js{}
    end
  end

  private

  def same_graduate_course_required
    teacher = Teacher.find(params[:id])
    teacher_ids = teacher.user.graduate_course_ids
    current_user_ids = @current_user.graduate_course_ids
    common_ids = current_user_ids & teacher_ids
    if common_ids == [] && teacher_ids.size != 0
      flash[:error] = "Questo docente non appartiene a nessun tuo corso di laurea"
      redirect_to timetables_url
    end
  end

  def same_teacher_required
    unless @current_user == User.find(:first, :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", params[:id]])
      flash[:error] = "Non puoi modificare un utente diverso dal tuo"
      redirect_to timetables_url
    end
  end
  
end
