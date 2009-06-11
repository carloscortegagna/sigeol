#=QuiXoft - Progetto SIGEOL
#NOME FILE:: building.rb
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/2009
#REGISTRO DELLE MODIFICHE::
# 20/04/2009 Approvazione del responsabile
#
# 13/03/2009 Aggiunta del metodo validates_associated :address
#
# 20/02/2009 Modifica all'espressione regolare che valida il nome del palazzo
#
# 17/02/2009 Aggiunta delle validazioni
#
# 16/02/2009 Prima stesura
#
#Rappresentazione di un edificio contenente le aule (_Classroom_).

class Building < ActiveRecord::Base
  include ApplicationHelper

 belongs_to :address, :dependent => :destroy
 has_many :classrooms, :dependent => :destroy
 
 #validazioni :name
 validates_uniqueness_of :name,
                         :message=>"Esiste già un palazzo con questo nome"
 validates_presence_of :name,
                       :message=>"Il nome non deve essere vuoto"
 validates_length_of :name,
                     :maximum=> 30,
                     :message=>"Il nome è troppo lungo"
 validates_format_of :name,
                     :with => /^[a-zA-Z0-9àòèéùì\s]*$/,
                     :message=>"Si accettano solo caratteri alfanumerici"
 #validazione presenza indirizzo
  validates_associated :address,
                       :message=>"Immetti un indirizzo valido"

  #Override del metodo della super classe per impostare il primo carattere del nome in maiusculo
  #ed i rimanenti in minuscolo, prima delle validazioni.
  def before_validation
      self.name=first_upper(self.name)
    end
end