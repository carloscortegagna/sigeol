# QuiXoft - Progetto ”SIGEOL”
# NOME FILE: users.controller.rb
# AUTORE: Beggiato Andrea
# DATA CREAZIONE: 22/02/2009
# 
# REGISTRO DELLE MODIFICHE:
#
# 28/05/2009 aggiunte modifiche su edit inserendo le righe 21 e 22.
#aggiunte modifiche ad update inserendo le istruzioni utili al controllo della password.
# 
# 02/03/2009 cambiato il nome del filtro :same_user in :same_user_required
#
# 22/02/2009 prima stesura del file

class UsersController < ApplicationController
  before_filter :same_user_required
  require 'digest/sha1'

  # modifica della password utente
  def edit
    @current_user
    @old_password = 1
    @repeat_password = 1
  end

  # salvataggio nel DB della nuova password
  def update
    @old_password = Digest::SHA1.hexdigest(params[:old_password])
    @password = params[:user][:password]
    @repeat_password = params[:repeat_password]
    respond_to do |format| 
    if  @old_password == @current_user.password 
       @old_password = 1
    else  
      @old_password = 0
    end
    if  @repeat_password == @password
       @repeat_password = 1
    else  
      @repeat_password = 0
    end
    if @current_user.update_attributes(params[:user]) && @old_password == 1 && @repeat_password == 1
        flash[:notice] = "Password cambiata con successo"
        format.html{redirect_to timetables_url}
        format.js{render(:update) {|page| page.redirect_to timetables_url}}
     end
     format.html{render :action => :edit}
     format.js{}
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