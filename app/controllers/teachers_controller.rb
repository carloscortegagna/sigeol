#=QuiXoft - Progetto SIGEOL
#NOME FILE:: teachers.controller.rb
#AUTORE:: Beggiato Andrea, Scortegagna Carlo
#DATA CREAZIONE:: 17/02/2009
#REGISTRO DELLE MODIFICHE::
# 05/06/2009 aggiunta l'action manage_constraints
#
# 28/09/2009 aggiunta in administration la lista dei docenti non associati a nessun corso di laurea
# 
# 19/05/2009 sistemate le action index e show per gli utenti non loggati
#
# 12/05/2009 sia su proprity_down che su priority_up assegnato a i = constraint_to_move_down.isHard.
# Usato i come indice per accedere ai valori degli array e non piu' constraint_to_move_down.isHard(riga 292 e 323)
# 
# 12/05/2009 per gli array e' stato sostituito count con size
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
                                                     :update_graduate_courses, :manage_constraints,:transform_constraint_in_preference,:destroy_constraint_from_manage_constraints]
  before_filter :manage_capabilities_required, :only => [:edit_capabilities, :update_capabilities]
  before_filter :same_graduate_course_required, :only => [:edit_graduate_courses, :update_graduate_courses,
                                                          :edit_capabilities, :update_capabilities]
  before_filter :same_teacher_required, :only => [:edit, :update_personal_data, :edit_constraints, :edit_preferences,
                                                          :create_constraint, :destroy_constraint]
  before_filter :teacher_in_use, :only => [:edit_constraints, :edit_preferences,:create_constraint, :destroy_constraint]

  # Inizializza la variabile d'istanza @teachers per la vista index.
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

  # Inizializza le variabili d'istanza @teacher e @user per la vista show.
  def show
    notfound = false
    @teacher = Teacher.find(params[:id]) rescue notfound = true
    unless notfound
      @user = User.find(:first, :include => :address,
              :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", params[:id]])
    end
      respond_to do |format|
        format.html {
          if notfound
            redirect_to :controller => 'timetables', :action => 'not_found'
          end
          }
        format.xml {
          if notfound
            redirect_to :controller => 'timetables', :action => 'not_found'
          else
            render :xml => @user.to_xml(:include => [:address], :except =>[:created_at, :updated_at, :digest, :password, :random])
          end
        }
    end
  end

  # Inizializza le variabili d'istanza @teacher, @manageable_graduate_courses e @selectable_graduate_courses per la vista edit_graduate_courses.
  def edit_graduate_courses
    total_graduate_courses = @current_user.graduate_courses
    @teacher = Teacher.find(params[:id])
    teacher_graduate_courses = @teacher.user.graduate_courses
    @manageable_graduate_courses = total_graduate_courses & teacher_graduate_courses
    @selectable_graduate_courses = total_graduate_courses - teacher_graduate_courses
  end

  # Inizializza le variabili d'istanza @teacher, @manageable_capabilities e @selectable_capabilities per la vista edit_capabilities.
  def edit_capabilities
    total_capabilities = @current_user.capabilities
    @teacher = Teacher.find(params[:id])
    teacher_capabilities = @teacher.user.capabilities
    @manageable_capabilities = total_capabilities & teacher_capabilities
    @selectable_capabilities = total_capabilities - teacher_capabilities
  end

  # Gestisce le associazioni tra i teachers e i graduate_courses.
  # - Se la chiamata e' una delete, viene eliminato il riferimento tra il docente passato come
  #   parametro (params[:id]) e il corso di laurea (params[:ids]).
  # - Se la chiamata e' un put, viene creata l'associazione tra il docente e il corso di laurea.
  # In entrambi i casi, al termine del metodo viene fatto un redirect alla vista edit_graduate_courses.
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
      format.html {edit_graduate_courses
                  render :action => "edit_graduate_courses"}
      format.js {edit_graduate_courses}
    end
  end

  # Gestisce le associazioni tra i teachers e le capability.
  # - Se la chiamata e' una delete, viene eliminato il riferimento tra il docente passato come
  #   parametro (params[:id]) e il privilegio (params[:ids]).
  # - Se la chiamata e' un put, viene creata l'associazione tra il docente e il privilegio.
  # In entrambi i casi, al termine del metodo viene fatto un redirect alla vista edit_capabilities.
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
                    render :action => "edit_capabilities"}
      format.js {edit_capabilities}
    end
  end

  # Crea una nuova variabile d'istanza vuota @teacher e inizializza @graduate_courses per la vista new,
  # in cui e' possibile invitare un docente inserendo il suo indirizzo email.
  def new
    @teacher = User.new()
    @graduate_courses = @current_user.graduate_courses
  end

  # Gestisce il salvataggio nel DB del nuovo teacher invitato.
  # - Se la mail passata come parametro (params[:mail]) non corrisponde a nessun utente gia' registrato,
  #   viene gestita la creazione nel DB dei dati relativi al teacher, allo user e al relativo address.
  #   Con la chiamata al metodo TeacherMailer.deliver_activate_teacher viene in seguito spedita una e-mail
  #   al docente invitato, in cui gli si da la possibilita' di completare la registrazione al sistema
  #   inserendo i propri dati personali.
  # - Nel caso la mail passata come parametro (params[:mail]) corrisponda ad un utente gia' registrato e
  #   il corso di laurea scelto per l'invito (params[:graduate_course_id]) sia diverso da quello precedentemente selezionato,
  #   il docente viene associato al nuovo corso di laurea (mantenendo comunque l'associazione con quello precedente).
  # - Nel caso la mail passata come parametro (params[:mail]) corrisponda ad un utente non di tipo teacher,
  #   viene segnalato l'errore.
  # In tutti i casi, al termine delle operazioni viene fatto un redirect alla vista new.
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
      if params[:graduate_course_id]
        @teacher.graduate_courses << GraduateCourse.find(params[:graduate_course_id])
      end
        if @teacher.save
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
          if params[:graduate_course_id]
            user.graduate_courses << GraduateCourse.find(params[:graduate_course_id])
          end
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

  # Elimina definitivamente dal sistema il teacher (e il relativo user) passato come parametro (params[:id])
  # Al termine della cancellazione viene fatto un redirect alla vista administration.
  def destroy
    @user = User.find(:first, :include => :address,
            :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", params[:id]])
    @teacher = Teacher.find(@user.specified_id)
    @teacher.destroy
    @user.address.destroy
    @user.destroy
    redirect_to(administration_teachers_url)
  end

  # Inizializza la variabile d'istanza @user per la vista edit.
  def edit
    teacher = Teacher.find(params[:id])
    @user = User.find(:first, :include => :address,
            :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", teacher.id])
  end

  # Aggiorna i campi dato dell'address del teacher passato come parametro (params[:id]).
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

  # Inizializza le variabili d'istanza @user e @repeat_password per la vista pre_activate, in cui
  # un teacher puo' completare la propria registrazione al sistema.
  def pre_activate
    @user = User.find params[:id]
    @repeat_password = 1
    unless @user != nil && @user.specified_type == "Teacher" && !@user.active? && @user.digest == params[:digest]
      flash[:notice] = "Questo docente è già attivo o non esiste"
      redirect_to timetables_url
    end
  end

  # Completa la registrazione del teacher nel sistema, inserendo nel DB i dati realtivi all'address,
  # la password scelta e i dati personali del docente.
  # Nel caso di utente gia' attivo o inesistente, viene segnalato l'errore e viene fatto un redirect
  # alla vista index di timetables.
  def activate
    @repeat_password = params[:repeat_password]
    @user = User.find params[:id]
    respond_to do |format|
      if @user != nil && @user.specified_type == "Teacher" && !@user.active? && @user.digest == params[:digest]
        @user.address.telephone= ""
        if(params[:prefisso] != "" || params[:telefono] != "")
          @user.address.telephone = params[:prefisso]+"-"+params[:telefono]
        end
        if @repeat_password == params[:user][:password]
          @repeat_password = 1
        else
          @repeat_password = 0
        end
        if @user.specified.update_attributes(params[:teacher]) && @user.address.update_attributes(params[:address]) &&  @repeat_password == 1
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
        format.html{redirect_to timetables_url}
        format.js{render(:update) {|page| page.redirect_to timetables_url}}
      end
    end
  end

  # Inizializza le variabili d'istanza @not_associated_users, @graduate_courses e @not_active_users
  # per la vista administration.
  def administration
    # lista degli user (docenti) già attivi ma che non sono associati a nessun corso di laurea
    @not_associated_users = User.find(:all, :include => :graduate_courses,
                :conditions => ["specified_type = 'Teacher' AND graduate_courses.id IS null AND users.password is NOT null"])
              
    ids = @current_user.graduate_course_ids
    @graduate_courses = GraduateCourse.find(:all, :include => :users,
                :conditions => ["specified_type = 'Teacher' AND users.password is NOT null AND graduate_courses.id IN (?)",ids])

    # lista degli users che non hanno ancora completato la registrazione
    @not_active_users = User.find(:all, :include =>:graduate_courses,
                :conditions => ["users.password IS null AND graduate_courses.id IN (?)",ids])
  end

  # Inizializza le variabili d'istanza @teacher e @constraints per la vista edit_constraints,
  # in cui il teacher loggato puo' gestire i suoi temporal_constraints, i vincoli temporali di non disponibilita'.
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
    # Aggiunta parte per mostrare l'expirydate #
    total_graduate_courses = @current_user.graduate_courses
    teacher = Teacher.find(params[:id])
    teacher_graduate_courses = teacher.user.graduate_courses
    @manageable_graduate_courses = total_graduate_courses & teacher_graduate_courses
    @expiry_dates = []
    @number_of_real_expiry_dates = 0
    @manageable_graduate_courses.each do |mgc|
      exp_date = ExpiryDate.find(:all, :conditions => {:graduate_course_id => mgc.id})
      if exp_date.empty? == false
        first_exp_date = exp_date.first
        first_exp_date = nil
        exp_date = exp_date.sort_by { |k| k['date'] }
        exp_date.each do |ed|
          if ed.date >= Date.today()
            first_exp_date = ed
            break
          end
        end
        @expiry_dates << first_exp_date
        if first_exp_date != nil
          @number_of_real_expiry_dates += 1
        end
      else
        @expiry_dates << nil
      end
    end
    # Fine parte expirydate #
  end

  # Crea un nuovo temporal_constraints (vincolo) per il teacher loggato caratterizzato dal parametro params[:id].
  def create_constraint
    if request.post?
      day_nr = from_dayname_to_id(params[:day])
      t = TemporalConstraint.new(:description=>params[:description],
        :isHard=>0,:startHour=>params[:start_hour],:endHour=>params[:end_hour],:day=>day_nr)
      teacher = Teacher.find(params[:id])
      @constraint = t
      if t.save
        teacher.constraints << t
          @error_unique = !t.is_unique_constraint?(teacher)
      end
        respond_to do |format|
        @teacher = teacher
        format.html { edit_constraints
                      render :action => "edit_constraints"
        }
        format.js{}
      end
    end
  end

  # Elimina definitivamente il temporal_constraints (vincolo) identificato dal parametro params[:constraint_id]
  def destroy_constraint
    constraint_to_destroy = TemporalConstraint.find(params[:constraint_id])
    constraint_to_destroy.destroy
    respond_to do |format|
      @constraint = constraint_to_destroy
      #necessario per controllo `size` su js
      format.html { edit_constraints
                    render :action => "edit_constraints"}
      format.js { edit_constraints }
    end
  end

  # Inizializza le variabili d'istanza @teacher e @constraints per la vista edit_preferences,
  # in cui il teacher loggato puo' gestire le sue preferenze temporali di non disponibilita'.
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
    # Aggiunta parte per mostrare l'expirydate #
    total_graduate_courses = @current_user.graduate_courses
    teacher = Teacher.find(params[:id])
    teacher_graduate_courses = teacher.user.graduate_courses
    @manageable_graduate_courses = total_graduate_courses & teacher_graduate_courses
    @expiry_dates = []
    @number_of_real_expiry_dates = 0
    @manageable_graduate_courses.each do |mgc|
      exp_date = ExpiryDate.find(:all, :conditions => {:graduate_course_id => mgc.id})
      if exp_date.empty? == false
        first_exp_date = exp_date.first
        first_exp_date = nil
        exp_date = exp_date.sort_by { |k| k['date'] }
        exp_date.each do |ed|
          if ed.date >= Date.today()
            first_exp_date = ed
            break
          end
        end
        @expiry_dates << first_exp_date
        if first_exp_date != nil
          @number_of_real_expiry_dates += 1
        end
      else
        @expiry_dates << nil
      end
    end
    # Fine parte expirydate #
  end

  # Crea un nuovo temporal_constraints (preferenza) per il teacher loggato caratterizzato dal parametro params[:id].
  # - Se non sono presenti altre preferenze nel sistema, il valore di isHard della nuova preferenza sara' uguale a 1.
  # - Se sono gia' presenti altre preferenze, quella nuova verra' inserita in coda alle altre gia' presenti, con priorita' piu' bassa.
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
      @constraint = t
      if t.save
        teacher.constraints << t
          @error_unique = !t.is_unique_constraint?(teacher)
      end
      respond_to do |format|
        format.html { edit_preferences
                      render :action => "edit_preferences"
        }
        format.js{ edit_preferences }
      end
    end
  end

  # Elimina definitivamente il temporal_constraints (preferenza) identificato dal parametro params[:constraint_id].
  # Se la cancellazione va a buon fine, i valori di isHard delle altre preferenze vengono aggiornati per ritornare
  # ad essere una sequenza di interi crescenti (partendo da 1).
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
    end
    respond_to do |format|
      @constraint = constraint_to_destroy
      format.html { edit_preferences
                    render :action => "edit_preferences"
      }
      format.js{ edit_preferences }
      end
  end

  # Aumenta la priorita' della preferenza passata come parametro (params[:constraint_id]): il valore di isHard
  # diminuisce di 1, in quanto una priorita' piu' alta e' caratterizzata da un valore di isHard piu' basso.
  # Se invece la preferenza ha gia' priorita' massima (isHard == 1) non avvengono modifiche.
  def teacher_preference_priority_up
    constraint_to_move_up = TemporalConstraint.find(params[:constraint_id]) #preferenza di cui cambiare la priorità
    if constraint_to_move_up.isHard == 1 #la preferenza è la prima, non devo cambiare niente
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
    end
    respond_to do |format|
      @constraint_up = c1
      @constraint_down = c2
      @already_up = already_up
      format.html { edit_preferences
                    render :action => "edit_preferences"
      }
      format.js{edit_preferences}
    end
  end

  # Diminuisce la priorita' della preferenza passata come parametro (params[:constraint_id]): il valore di isHard
  # aumenta di 1, in quanto una priorita' piu' bassa e' caratterizzata da un valore di isHard piu' alto.
  # Se invece la preferenza ha gia' priorita' minima non avvengono modifiche.
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
    end
    respond_to do |format|
      @constraint_up = c2
      @constraint_down = c1
      @already_down = already_down
      format.html { edit_preferences
                    render :action => "edit_preferences"
      }
      format.js{edit_preferences}
    end
  end

  # Inizializza le variabili d'istanza @teacher, @constraints e @preferences per la vista manage_constraints, la quale
  # permette di gestire i vincoli e le preferenze del docente passato come parametro (params[:id]).
  def manage_constraints
    @teacher = Teacher.find(params[:id])
    teacher_constraint_ids = ConstraintsOwner.find(:all,
      :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Teacher' AND owner_id = (?)", params[:id]],
      :select => ['constraint_id'], :group => 'constraint_id')
    @constraints = []
    for c_id in teacher_constraint_ids do
      if TemporalConstraint.find(c_id.constraint_id).isHard == 0
        @constraints << TemporalConstraint.find(c_id.constraint_id)
      end
    end
    @preferences = []
    for p_id in teacher_constraint_ids do
      if TemporalConstraint.find(p_id.constraint_id).isHard != 0
        @preferences << TemporalConstraint.find(p_id.constraint_id)
      end
    end
    @preferences = @preferences.sort_by { |c| c[:isHard] }
  end

  # Elimina definitivamente il temporal_constraints passato come parametro, facendo in seguito un
  # redirect alla vista administration.
  def destroy_constraint_from_manage_constraints
    constraint_to_destroy = TemporalConstraint.find(params[:constraint_id])
    constraint_to_destroy.destroy
    redirect_to(administration_teachers_url)
  end

  # Trasformare il temporal_constraints (vincolo) passato come parametro in una preferenza.
  # La nuova preferenza ha priorita' massima: il valore isHard di tutte le preferenze precedentemente inserite
  # viene aumentato di 1.
  def transform_constraint_in_preference
    teacher = Teacher.find(params[:teacher])
    constraint_to_transform_in_preference = TemporalConstraint.find(params[:constraint_id])
    teacher_constraint_ids = ConstraintsOwner.find(:all,
          :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Teacher' AND owner_id = (?)", params[:teacher]],
          :select => ['constraint_id'], :group => 'constraint_id')
    TeacherMailer.deliver_constraint_in_preference(@current_user,teacher.user,constraint_to_transform_in_preference)
    preferences = []
    for id in teacher_constraint_ids do
      if TemporalConstraint.find(id.constraint_id).isHard != 0
       preferences << TemporalConstraint.find(id.constraint_id)
      end
    end
    preferences.each do |p|
      p.isHard = p.isHard + 1
      p.save
    end
    constraint_to_transform_in_preference.isHard = 1
    constraint_to_transform_in_preference.description = "Preferenza docente: " + teacher.name + " " + teacher.surname
    constraint_to_transform_in_preference.save
    redirect_to(administration_teachers_url)
  end
  
  private

  # Controlla che lo User attualmente loggato possa gestire il teacher passato come parametro (params[:id]).
  # In caso negativo, viene fatto un redirect all'index di timetables e viene segnalato l'errore.
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

  # Controlla che il teacher loggato corrisponda al teacher caratterizzato dal parametro params[:id].
  def same_teacher_required
    unless @current_user == User.find(:first, :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", params[:id]])
      flash[:error] = "Non puoi modificare un utente diverso dal tuo"
      redirect_to timetables_url
    end
  end

  def teacher_in_use
    teacher = Teacher.find(params[:id])
    user = teacher.user
    graduate_courses = user.graduate_courses
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
      flash[:error] = "Non è possibile modificare le preferenze ed i vincoli in quanto è in corso la generazione dell'orario per il corso di laurea " +name
      redirect_to timetables_url
    end
  end
end
