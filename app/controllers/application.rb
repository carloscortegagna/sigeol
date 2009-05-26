# QuiXoft - Progetto ”SIGEOL”
# NOME FILE: application.rb
# AUTORE: Beggiato Andrea
# DATA CREAZIONE: 06/02/2009
#
# REGISTRO DELLE MODIFICHE:
#
# 08/05/2009 aggiunti i metodi di conversione [id->giorno = from_id_to_dayname] e [giorno->id = from_dayname_to_id];
#
# 18/02/2009 completata la gestione delle capabilities
#
# 13/02/2009 creato il filtro login_required



# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => '3fe1cdf693d8174fbb2980492c6206ec'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  before_filter :login_required

    def login_required
    respond_to do |format|
      format.html do
        if session[:user_id]
          @current_user = User.find(session[:user_id])
        else
          flash[:notice] = "Effettuare il login"
          redirect_to new_session_url
        end
      end
    end
  end

  def manage_teachers_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_teachers?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  def manage_capabilities_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_capabilities?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end
  def manage_graduate_courses_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_graduate_courses?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end
  def manage_classrooms_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_classrooms?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  def manage_buildings_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_buildings?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  def manage_teachings_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_teachings?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end
  def didactic_office_required
    if @current_user == nil || !@current_user.active? || !@current_user.own_by_didactic_office?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  def from_id_to_dayname(id)
   day_name=case id
      when 1 then "Lunedi"
      when 2 then "Martedi"
      when 3 then "Mercoledi"
      when 4 then "Giovedi"
      when 5 then "Venerdi"
   end
   day_name
 end

 def from_dayname_to_id(name)
  day_nr = case name
    when "Lunedi" then 1
    when "Martedi"then 2
    when "Mercoledi" then 3
    when "Giovedi" then 4
    when "Venerdi" then 5
    else 0
  end
  day_nr
 end

end
