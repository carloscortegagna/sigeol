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

  before_filter :login_required, :except => :info

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

  def menage_teachers_required
    cap = @current_user.capabilities.find_by_name("Menage teachers")
    if @current_user == nil || cap == nil
      flash[:error] = "Non possiedi i privilegi per effettuare questa operazione"
      redirect_to timetables_url
    end
  end

end
