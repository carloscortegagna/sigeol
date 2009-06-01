#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: teacher.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 12/02/09
#REGISTRO DELLE MODIFICHE::
# 21/04/09 Approvazione del responsabile
#
# 10/03/09 Aggiunta dell'associazione polimorfa has_many :constraints
#
# 26/02/09 Override del metodo before_destroy
#
# 15/02/09 Corrette le restrizioni su alcune validazioni
#
# 13/02/09 Aggiunta delle validazioni
#
# 12/02/09 Prima stesura
#
#Rappresentazione di un docente. Utilizzato per la creazione dello _User_ associato ad un docente. Contiene
#inoltre i dati personali del docente.

class Teacher < ActiveRecord::Base

  include ApplicationHelper

  has_many :constraints, :dependent=> :destroy
  has_one :user, :as => :specified
  has_many :teachings

  #validazioni attributo :name e :surname
  validates_presence_of :name, :surname,
                        :message=>"Il campo non deve essere vuoto",
                        :on => :update
  validates_length_of :name,:surname,
                      :maximum=> 30,
                      :message=>"Il campo è troppo lungo",
                      :on => :update
  validates_format_of :name,:surname,
                      :with => /^[a-zA-Zàòèéùì\s]*$/,
                      :message=>"Si accetta solo caratteri",
                      :on => :update

  #Override del metodo della super classe per impostare il primo carattere del nome e del cognome in maiusculo
  #ed i rimanenti in minuscolo, prima delle validazioni.
  def before_validation
    self.name=first_upper(self.name)
    self.surname=first_upper(self.surname)
  end

  #Override del metodo della super classe per eliminare lo _User_ corrispondente all'oggetto d'invocazione
  #prima dell'eliminazione dello stesso.
  def before_destroy
    u=User.find_by_specified_id_and_specified_type(self.id,"Teacher")
    u.delete
  end

  #Restituisce il nome completo del docente, composto dal cognome concatenato ad uno spazio seguito dal nome.
  def complete_name
    self.surname + " " + self.name
  end
end