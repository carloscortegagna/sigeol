#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: expiry_date.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/09
#REGISTRO DELLE MODIFICHE::
# 29/04/09 Approvazione del responsabile
#
# 28/02/09 Aggiunta nel metodo correct_date dell'istruzione self.date.to_date
#
# 27/02/09 Aggiunta del metodo is_correct_date?
#
# 14/02/09 Aggiunta delle validazioni
#
# 16/02/09 Prima stesura
#
#Rappresentazione di una data di scadenza per l'immissione di vincoli e preferenze
#riguardante aule, docenti e corsi di laurea. Utilizzata iniltre per la schedulazione
#programmata della generazione dell'orario.

class ExpiryDate < ActiveRecord::Base
  belongs_to :graduate_course

 validates_presence_of :period,
                         :message=>"Inserisci il periodo associato alla data"

  validates_numericality_of :period,
                            :only_integer =>true,
                            :greater_than_or_equal_to =>1,
                            :less_than_or_equal_to =>10,
                            :message=>"Attenzione il periodo deve essere compreso tra 1 e 10"

  validates_presence_of :date,
                        :message=>"La data non deve essere vuota"

  validates_presence_of  :graduate_course_id,
                        :message=>"Deve essere associata ad un corso di laurea"

  validate :is_correct_date?

  private

  #Aggiunge all'oggetto +errors+, contenente gli errori di validazione, un ulteriore messaggio
  #se la data che si intende inserire è antecedente a quella odierna.
  def is_correct_date? #:doc:
    if self.date
      self.date.to_date;
        if self.date.past?
          errors.add(:date,"La data deve essere maggiore di quella di oggi(#{::Date.current}).")
      end
    end
  end
end