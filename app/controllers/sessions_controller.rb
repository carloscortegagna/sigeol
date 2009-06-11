#=QuiXoft - Progetto SIGEOL
#NOME FILE:: sessions.controller.rb
#AUTORE:: Beggiato Andrea
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
# 17/02/2009 modifica dei redirect
#
# 13/02/2009 prima stesura del session controller

class SessionsController < ApplicationController
  skip_before_filter :login_required

  # Genera la vista new di sessions
  def new
    respond_to do |format|
      format.html
    end
  end

  # Verifica che lo username (params[:mail]) e la password ([:password]) siano corretti tramite la chiamata User.authenticate.
  # In caso di esito positivo il login e' da considerarsi effettuato con successo, l'id dell'utente viene inserito
  # nella sessione corrente e viene fatto un redirect all'index di timetables.
  # In caso di esito negativo (mail o password errati) viene fatto un redirect all'index di timetables con la segnalazione dell'errore.
  def create
    user = User.authenticate(params[:mail], params[:password])
    if user && user.active?
      session[:user_id] = user.id
      flash[:notice] = "Login effettuato con successo."
      redirect_to timetables_url
    else
      flash[:error] = "E-mail o password errati."
      redirect_to timetables_url
    end
  end

  # Effettua il logout dell'utente oggetto dell'invocazione facendo un reset della sessione.
  # La variabile d'istanza viene impostata nulla e viene fatto un redirect all'index di timetables.
  def destroy
    reset_session
    @current_user = nil
    flash[:notice] = "Logout effettuato con successo."
    redirect_to timetables_url
  end
end
