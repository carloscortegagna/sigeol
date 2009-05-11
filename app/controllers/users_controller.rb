class UsersController < ApplicationController
  before_filter :same_user_required

  def edit
    @current_user
  end

  def update
    if @current_user.update_attributes(params[:user])
      flash[:notice] = "Password cambiata con successo"
      redirect_to timetables_url
    else
      render :action => :edit
    end
  end
  private

  def same_user_required
    unless @current_user == User.find(params[:id])
      flash[:error] = "Non puoi modificare un utente diverso dal tuo"
      redirect_to timetables_url
    end
  end
end

#def xml
#  @users = Building.find(:all)
#  respond_to do |accepts|
#    accepts.xml { render :xml => @users.to_xml }
#  end