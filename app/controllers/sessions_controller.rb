class SessionsController < ApplicationController
  skip_before_filter :login_required
  def new
  end

  def create
    user = User.authenticate(params[:mail], params[:password])
    if user && user.active?
      session[:user_id] = user.id
      flash[:notice] = "Login effettuato con successo."
      redirect_to timetables_url
    else
      flash[:error] = "E-mail o password errati."
      render :action => :new
    end
  end

  def destroy
    reset_session
    flash[:notice] = "Logout effettuato con successo."
    redirect_to new_session_url
  end

end
