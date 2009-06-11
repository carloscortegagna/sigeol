#=QuiXoft - Progetto SIGEOL
#NOME FILE:: didactic_office.rb
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 12/02/2009
#REGISTRO DELLE MODIFICHE::
# 29/04/2009 Approvazione del responsabile
# 
# 22/02/2009 Aggiunta del metodo before_destroy
#
# 16/02/2009 Prima stesura
#
#Rappresentazione di una segreteria didattica. Utilizzato per la creazione dello _User_ associato ad una segreteria didattica.

class DidacticOffice < ActiveRecord::Base
  has_one :user, :as => :specified

  #Override del metodo della super classe per eliminare lo _User_ corrispondente all'oggetto d'invocazione
  #prima dell'eliminazione dello stesso.
  def before_destroy
   u=User.find_by_specified_id_and_specified_type(self.id,"DidacticOffice")
   u.delete
  end
end
