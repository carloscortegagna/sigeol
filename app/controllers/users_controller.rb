# QuiXoft - Progetto ”SIGEOL”
# NOME FILE: users.controller.rb
# AUTORE: Beggiato Andrea
# DATA CREAZIONE: 22/02/2009
# 
# REGISTRO DELLE MODIFICHE:
# 
# 02/03/2009 cambiato il nome del filtro :same_user in :same_user_required
#
# 22/02/2009 prima stesura del file

class UsersController < ApplicationController
  before_filter :same_user_required

  # modifica della password utente
  def edit
    @current_user
  end

  # salvataggio nel DB della nuova password
  def update
    if @current_user.update_attributes(params[:user])
      flash[:notice] = "Password cambiata con successo"
      redirect_to timetables_url
    else
      render :action => :edit
    end
  end

  private

  # filtro che impedisce la modifica della password di un utente diverso da quello corrente
  def same_user_required
    unless @current_user == User.find(params[:id])
      flash[:error] = "Non puoi modificare un utente diverso dal tuo"
      redirect_to timetables_url
    end
  end
  
end