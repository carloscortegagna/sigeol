#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: address.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 16/02/09
#REGISTRO DELLE MODIFICHE:
#27/02/09 Diminuite da 15 a 13 il numero di cifre per il numero di telefono
#20/02/09 Piccole correzioni alle espressioni regolari
#17/02/09 Aggiunta delle validazioni
#16/02/09 Prima stesura

class Address < ActiveRecord::Base
  include ApplicationHelper
  has_one :user
  has_one :building
  
  #validazioni :city
   validates_presence_of :city,
                         :message => "Inserisci la città"

  validates_length_of :city,
                      :maximum => 30,
                      :message => "Il nome è troppo lungo"

  validates_format_of :city,
                      :with => /^[a-zA-Zàòèéùì\s]*$/,
                      :message => "Si accetta solo caratteri"

#validazioni :phone
      validates_length_of :telephone,
                          :maximum => 13,
                          :message => "Il numero di telefono è troppo lungo"
     validates_format_of :telephone,
                     :with => /^[0-9]{2,4}\-[0-9]{6,8}$/,
                     :message => "Inserisci in questo modo: prefisso-numero"

#validazioni :street
   validates_presence_of :street,
                         :message => "Inserisci la via"
   validates_length_of :street,
                       :maximum => 50,
                       :message => "Il nome della via è troppo lungo"
   validates_format_of :street,
                     :with => /^[a-zA-Z0-9àòèéùì\s]*$/,
                     :message=>"Si accetta solo caratteri"

def before_save
   self.city=first_upper(self.city)
   self.street=first_upper(self.street)
end


end

