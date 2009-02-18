class TeachersController < ApplicationController
  skip_before_filter :login_required, :only => [:index, :activate]
  before_filter :manage_teachers_required, :only => [:new, :create]
  def index
    @teachers = User.find_by_specified_type("Teacher")
  end

  def new
    @teacher = User.new()
  end

  def create
    user = User.new()
    user.mail = params[:mail]
    user.random = rand(120)
    teacher = Teacher.new()
    user.specified = teacher
    if user.save
      flash[:notice] = "Docente invitato con successo"
      redirect_to new_teacher_url
    else
      flash[:error] = user.errors.full_messages.to_s
      teacher.destroy
      redirect_to new_teacher_url
    end
  end

  def pre_activate
    if params[:digest]
      @user = User.find_by_digest params[:digest]
      if @user == nil || @user.active?
        flash[:error] = "L'utente non esiste od è già attivo"
        redirect_to timetables_url
      end
    else
      redirect_to timetables_url
    end
  end

  def activate
    @user = User.find params[:user]
    teacher = @user.specified
    teacher.name = params[:name]
    teacher.surname = params[:surname]
    if teacher.save
      @user.password = params[:password]
      if @user.save
        flash[:notice] = "Account attivato correttamente"
        redirect_to timetables_url
      else
        flash[:errors] = @user.errors.full_messages.to_s
        redirect_to :action => :pre_activate, :digest => @user.digest
      end
    else
      flash[:errors] = teacher.errors.full_messages.to_s
      redirect_to :action => :pre_activate, :digest => @user.digest
    end
  end
end