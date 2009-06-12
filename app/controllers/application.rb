#=QuiXoft - Progetto SIGEOL
#NOME FILE:: application.rb
#AUTORE:: Beggiato Andrea
#DATA CREAZIONE:: 06/02/2009
#REGISTRO DELLE MODIFICHE::
# 08/05/2009 aggiunti i metodi di conversione [id->giorno = from_id_to_dayname] e [giorno->id = from_dayname_to_id];
#
# 18/02/2009 completata la gestione delle capabilities
#
# 13/02/2009 creato il filtro login_required
# 
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

  # Filtro da applicare a tutte quelle operazioni che possono essere effettuate solamente dopo essersi loggati con successo al sistema
  # Il filtro non permette l'accesso alla pagina richiesta ed effettua un redirect all'index di timetables se:
  # - non e' loggato nessuno _User_, e quindi session[:user_id] e' vuoto
  # Nel caso session[:user_id] non sia vuoto, lo _User_ identificato da user_id viene associato alla variabile @current_user
  def login_required
    respond_to do |format|
      format.html do
        if session[:user_id]
          @current_user = User.find(session[:user_id])
        else
          flash[:notice] = "Si prega di effettuare il login"
          redirect_to timetables_url
        end
      end
    end
  end

  # Filtro da applicare a tutte quelle operazioni che richiedono il possesso della capability manage_teachers
  # Il filtro non permette l'accesso ed effettua un redirect all'index di timetables se:
  # - non e' loggato nessun utente
  # - l'utente loggato non e' ancora attivo
  # - l'utente loggato non possiede la capability manage_teachers
  def manage_teachers_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_teachers?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  # Filtro da applicare a tutte quelle operazioni che richiedono il possesso della capability manage_timetables
  # Il filtro non permette l'accesso ed effettua un redirect all'index di timetables se:
  # - non e' loggato nessun utente
  # - l'utente loggato non e' ancora attivo
  # - l'utente loggato non possiede la capability manage_teachers
  def manage_timetables_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_timetables?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  # Filtro da applicare a tutte quelle operazioni che richiedono il possesso della capability manage_capabilities
  # Il filtro non permette l'accesso ed effettua un redirect all'index di timetables se:
  # - non e' loggato nessun utente
  # - l'utente loggato non e' ancora attivo
  # - l'utente loggato non possiede la capability manage_capabilities
  def manage_capabilities_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_capabilities?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  # Filtro da applicare a tutte quelle operazioni che richiedono il possesso della capability manage_graduate_courses
  # Il filtro non permette l'accesso ed effettua un redirect all'index di timetables se:
  # - non e' loggato nessun utente
  # - l'utente loggato non e' ancora attivo
  # - l'utente loggato non possiede la capability manage_graduate_courses
  def manage_graduate_courses_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_graduate_courses?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  # Filtro da applicare a tutte quelle operazioni che richiedono il possesso della capability manage_classrooms
  # Il filtro non permette l'accesso ed effettua un redirect all'index di timetables se:
  # - non e' loggato nessun utente
  # - l'utente loggato non e' ancora attivo
  # - l'utente loggato non possiede la capability manage_classrooms
  def manage_classrooms_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_classrooms?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  # Filtro da applicare a tutte quelle operazioni che richiedono il possesso della capability manage_buildings
  # Il filtro non permette l'accesso ed effettua un redirect all'index di timetables se:
  # - non e' loggato nessun utente
  # - l'utente loggato non e' ancora attivo
  # - l'utente loggato non possiede la capability manage_buildings
  def manage_buildings_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_buildings?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  # Filtro da applicare a tutte quelle operazioni che richiedono il possesso della capability manage_teachings
  # Il filtro non permette l'accesso ed effettua un redirect all'index di timetables se:
  # - non e' loggato nessun utente
  # - l'utente loggato non e' ancora attivo
  # - l'utente loggato non possiede la capability manage_teachings
  def manage_teachings_required
    if @current_user == nil || !@current_user.active? || !@current_user.manage_teachings?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  # Filtro da applicare a tutte quelle operazioni che possono essere effettuate solamente da utenti che sono segreterie didattiche
  # Il filtro non permette l'accesso ed effettua un redirect all'index di timetables se:
  # - non e' loggato nessun utente
  # - l'utente loggato non e' ancora attivo
  # - l'utente loggato non e' di tipo didactic_office
  def didactic_office_required
    if @current_user == nil || !@current_user.active? || !@current_user.own_by_didactic_office?
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

  # Restituisce il numero intero corrispondente al giorno della settimana passato come paramentro
  # Il parametro name in ingresso dev'essere di tipo stringa
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
