class TeachersController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :activate]
  before_filter :manage_teachers_required, :only => [:new, :create, :administration, :edit_graduate_courses,
                                                     :update_graduate_courses]
  before_filter :manage_capabilities_required, :only => [:edit_capabilities, :update_capabilities]
  before_filter :same_graduate_course_required, :only => [:edit_graduate_courses, :update_graduate_courses,
                                                          :edit_capabilities, :update_capabilities]
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
    if request.delete? || params[:method] = "delete"
      t = Teacher.find(params[:id])
      t.user.graduate_courses.delete(GraduateCourse.find(params[:ids]))
    end
    if request.put? || params[:method] = "put"
      t = Teacher.find(params[:id])
      t.user.graduate_courses << (GraduateCourse.find(params[:ids]))
    end
    redirect_to administration_teachers_url("Corsi di laurea per il docente #{t.surname} #{t.name} aggiornati con successo")
  end

  def update_capabilities
    t = Teacher.find(params[:id])
    if request.delete? || params[:method] = "delete"
      t.user.capabilities.delete(Capability.find(params[:ids]))
      flash[:notice] = "Privilegi per il docente #{t.surname} #{t.name} aggiornati con successo"
    end
    if request.put? || params[:method] = "put"
      t.user.capabilities << (Capability.find(params[:ids]))
      flash[:notice] = "Privilegi per il docente #{t.surname} #{t.name} aggiornati con successo"
    end
      redirect_to administration_teachers_url
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
        flash[:errors] = "La mail inserita è già presente e non corrisponde ad un docente"
        redirect_to new_teacher_url
      end
    end
  end

  def pre_activate
    @user = User.find params[:id]
    if @user != nil && !@user.active? && @user.digest == params[:digest]
      @teachers = @user.specified
      @address = @user.address
    else
      flash[:error] = "L'utente non esiste od è già attivo"
      redirect_to timetables_url
    end
  end

  def activate
    @user = User.find params[:id]
    if @user != nil && !@user.active? && @user.digest == params[:digest]
      @teacher = @user.specified
      @address = @user.address
        if @teacher.update_attributes(params[:teacher])
          if @address.update_attributes(params[:address])
            @user.password = params[:user][:password]
            @user.address = @address
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
          render :action => :pre_activate, :digest => @user.digest
        end
    else
      flash[:error] = "L'utente non esiste od è già attivo"
      redirect_to timetables_url
    end
  end

  def administration
    gs = @current_user.graduate_courses
    ids = @current_user.graduate_course_ids
    @graduate_courses = gs.find(:all, :include => [:users],
                :conditions => ["specified_type = 'Teacher' AND users.password is NOT null"])
    @not_active_users = User.find(:all, :include => :graduate_courses,
                :conditions => ["users.password IS null AND graduate_courses.id IN (?)",ids])
    
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
end