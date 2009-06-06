#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: sessions.controller.rb
#AUTORE:: Beggiato Andrea
#DATA CREAZIONE:: 13/02/2009
#REGISTRO DELLE MODIFICHE::
# 17/02/2009 modifica dei redirect
#
# 13/02/2009 prima stesura del session controller
#



class SessionsController < ApplicationController
  skip_before_filter :login_required
  
  def new
    respond_to do |format|
      format.html
    end
  end

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

  def destroy
    reset_session
    @current_user = nil
    flash[:notice] = "Logout effettuato con successo."
    redirect_to timetables_url
  end
end
