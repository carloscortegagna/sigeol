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

  #validazioni :date attraverso l'uso del plugin validates_timeliness
    oggi=::Date.current()
    validates_date :date,
                   :after=>oggi,
                   :invalid_date_message=>"La data deve essere nella forma gg/mm/aaaa",
                   :after_message=>"La data deve essere maggiore della data di oggi"
                   
    validates_presence_of :date,
                          :message=>"La data non deve essere vuota"

#conversione in una data,fa gia il plugin
#   def before_save
#    self.date.to_date
 # end


end