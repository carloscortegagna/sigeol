#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: building.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 16/02/09
#REGISTRO DELLE MODIFICHE:
#13/03/09 Aggiunta del metodo validates_associated :address
#20/02/09 Modifica all'espressione regolare che valida il nome del palazzo
#17/02/09 Aggiunta delle validazioni
#16/02/09 Prima stesura

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
                     :message=>"Si accetta solo caratteri"
 #validazione presenza indirizzo
  validates_associated :address,
                          :message=>"Immetti un indirizzo valido"

  def before_validation
      self.name=first_upper(self.name)
    end
end
