class TeachersController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :show, :pre_activate, :activate]
  before_filter :manage_teachers_required, :only => [:new, :create, :administration, :edit_graduate_courses,
                                                     :update_graduate_courses]
  before_filter :manage_capabilities_required, :only => [:edit_capabilities, :update_capabilities]
  before_filter :same_graduate_course_required, :only => [:edit_graduate_courses, :update_graduate_courses,
                                                          :edit_capabilities, :update_capabilities]
  before_filter :same_teacher_required, :only => [:edit_constraints, :edit_preferences,
                                                          :create_constraint, :destroy_constraint]

  # metodi da aggiungere:
  # destroy
  # edit per i dati personali
  # update per i dati personali
  def index
    @teachers = User.find_by_specified_type("Teacher")
  end

  def show
    @teacher = Teacher.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @teacher }
    end
  end

  def edit_graduate_courses
    total_graduate_courses = @current_user.graduate_courses
    @teacher = Teacher.find(params[:id])
    teacher_graduate_courses = @teacher.user.graduate_courses
    @manageable_graduate_courses = total_graduate_courses & teacher_graduate_courses
    @selectable_graduate_courses = total_graduate_courses - teacher_graduate_courses
  end

  def edit_capabilities
    total_capabilities = @current_user.capabilities
    @teacher = Teacher.find(params[:id])
    teacher_capabilities = @teacher.user.capabilities
    @manageable_capabilities = total_capabilities & teacher_capabilities
    @selectable_capabilities = total_capabilities - teacher_capabilities
  end

  def update_graduate_courses
    t = Teacher.find(params[:id])
    if request.delete?
      t.user.graduate_courses.delete(GraduateCourse.find(params[:ids]))
    end
    if request.put?
      t.user.graduate_courses << (GraduateCourse.find(params[:ids]))
    end
    flash[:notice] = "Corsi di laurea per il docente #{t.surname} #{t.name} aggiornati con successo"
    redirect_to administration_teachers_url
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
        format.html {
          flash[:notice] = "Privilegi per il docente #{@teacher.surname} #{@teacher.name} aggiornati con successo"
          redirect_to administration_teachers_url
        }
        format.js {}
      end
  end

  def new
    @teacher = User.new()
    @graduate_courses = @current_user.graduate_courses
  end

  def create
    user = User.find_by_mail(params[:mail])
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
        redirect_to new_teacher_url
      else
        @graduate_courses = @current_user.graduate_courses
        render :action => :new
      end
    else
      if user.own_by_teacher?
        user.graduate_courses << GraduateCourse.find(params[:graduate_course_id])
        flash[:notice] = "Docente invitato con successo"
        redirect_to new_teacher_url
      else
        flash[:error] = "La mail inserita è già presente e non corrisponde ad un docente"
        redirect_to new_teacher_url
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
    if @user != nil && @user.specified_type == "Teacher" && !@user.active? && @user.digest == params[:digest]
        if @user.specified.update_attributes(params[:teacher]) && @user.address.update_attributes(params[:address])
            @user.password = params[:user][:password]
            if @user.save
              flash[:notice] = "Account attivato correttamente"
              redirect_to timetables_url
            else
              render :action => :pre_activate, :digest => @user.digest
            end
        else
          render :action => :pre_activate, :digest => @user.digest
        end
    else
      flash[:error] = "L'utente non esiste od è già attivo"
      redirect_to timetables_url
    end
  end

  def administration
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
      t = TemporalConstraint.new(:description=>params[:description],
        :isHard=>0,:startHour=>params[:start_hour],:endHour=>params[:end_hour],:day=>params[:day])
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
      end
      redirect_to edit_constraints_teacher_url
    end
  end

  def destroy_constraint
    constraint_to_destroy = TemporalConstraint.find(params[:constraint_id])
    constraint_to_destroy.destroy
    redirect_to edit_constraints_teacher_url
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
      teacher_constraint_ids = ConstraintsOwner.find(:all,
          :conditions => ["constraint_type = 'TemporalConstraint' AND owner_type = 'Teacher' AND owner_id = (?)", params[:id]],
          :select => ['constraint_id'], :group => 'constraint_id')
      constraints = []
      for id in teacher_constraint_ids do
        if TemporalConstraint.find(id.constraint_id).isHard != 0
         constraints << TemporalConstraint.find(id.constraint_id)
        end
      end
      preference_value = constraints.count + 1 #conto il numero delle preferenze nel db e metto la giusta priorità a quella nuova
      t = TemporalConstraint.new(:description=>"Preferenza docente: " + teacher.name + " " + teacher.surname,
        :isHard=>preference_value,:startHour=>params[:start_hour],:endHour=>params[:end_hour],:day=>params[:day])     
      teacher_graduate_courses = teacher.user.graduate_courses
      if t.save
        for c in teacher_graduate_courses #devo creare un record in constraint_owner per ogni graduate_course del teacher
          co=ConstraintsOwner.new
          co.constraint=t
          co.graduate_course=GraduateCourse.find(c.id)
          co.owner = teacher
          co.save
        end
      end
      redirect_to edit_preferences_teacher_url
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
      flash[:notice] = "Preferenza eliminata con successo"
      redirect_to edit_preferences_teacher_url
    else
      flash[:error] = "Errore: preferenza non eliminata"
      redirect_to edit_preferences_teacher_url
    end
  end

  def teacher_preference_priority_up
    redirect_to edit_preferences_teacher_url
  end

  def teacher_preference_priority_down
    redirect_to edit_preferences_teacher_url
  end

  private

  def same_graduate_course_required
    teacher = Teacher.find(params[:id])
    teacher_ids = teacher.user.graduate_course_ids
    current_user_ids = @current_user.graduate_course_ids
    common_ids = current_user_ids & teacher_ids
    if common_ids == []
      flash[:error] = "Questo docente non appartiene a nessun tuo corso di laurea"
      redirect_to timetables_url
    end
  end

  def same_teacher_required
    #l'unless commentato è più sensato e mi sembra sia corretto, ma non funziona...quindi ripiego su quello sotto (bruttino...)
    #unless @current_user == User.find(:all, :conditions => ["specified_type = 'Teacher' AND specified_id = (?)", Teacher.find(params[:id])])
    unless @current_user.specified_id.to_s == params[:id]
      flash[:error] = "Non puoi modificare un utente diverso dal tuo"
      redirect_to timetables_url
    end
  end
  
end