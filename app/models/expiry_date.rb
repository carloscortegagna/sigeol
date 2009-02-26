#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: expiry_date.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#14/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura
class ExpiryDate < ActiveRecord::Base

  belongs_to :graduate_course

  validates_presence_of :date,
                        :message=>"La data non deve essere vuota"

end