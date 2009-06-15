#=QuiXoft - Progetto SIGEOL
#NOME FILE:: temporal_contraint.rb
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/2009
#REGISTRO DELLE MODIFICHE::
# 27/04/2009 Approvazione del responsabile
#
# 13/03/2009 Aggiunta validates_numericality_of :isHard
#
# 20/02/2009 Aggiunta delle validazioni
#
# 16/02/2009 Prima stesura
#
#Rappresentazione dei vincoli temporali. Con questa tipologia di vincolo si intendono le restrizioni del
#tipo, ad esempio, "l'aula è indisponibile il lunedì dalle 9:30 alle 12:30".

class TemporalConstraint < ActiveRecord::Base

  validates_numericality_of :isHard,
                          :only_integer => true,
                          :greater_than_or_equal_to => 0,
                          :less_than_or_equal_to => 10,
                          :message => "Deve essere compreso tra 1 e 10"

  #validazioni :startTime e :endTime e validazioni :day
  validates_presence_of :day,:description,:isHard,
                         :message=>"Alcuni campi sono vuoti"
                       
  validates_presence_of :startHour,
                         :message=>"Ora di inizio non valida"

  validates_presence_of :endHour,
                         :message=>"Ora di fine non valida"

  validates_numericality_of :day,
                            :only_integer => true,
                            :greater_than_or_equal_to => 1,
                            :less_than_or_equal_to => 5,
                            :message => "Deve essere compreso tra 1 e 5"
                     
  validate :is_correct_time?

  #Aggiunge all'oggetto +errors+, contentente gli errori di validazioni, un messaggio se esite già un'indisponibilità
   #con lo stesso periodo dell'oggetto d'invocazione nel database.
  def is_unique_constraint?(owner) #:doc:
    temporal = TemporalConstraint.find(:all,:conditions=>
        ["startHour = (?) AND endHour = (?) AND day = (?)",self.startHour, self.endHour, self.day]
    )
    if !temporal.empty?
   temporal.each do |t|
     if self != t && t.owners.first == owner
        if t.isHard == 0
         errors.add_to_base("Nel periodo indicato è già presente un VINCOLO")
        else
         errors.add_to_base("Nel periodo indicato è già presente una PREFERENZA")
       end
       self.destroy
       return false
     end
   end
 end
  return true
end

  private
  #Confronta l'orario di fine con quello iniziale del vincolo temporale, e se il primo risulta maggiore del secondo,
  #aggiunge un messaggio all'oggetto +errors+, contenente gli errori di validazione.
  def is_correct_time? #:doc:
   if(self.startHour && self.endHour && ( (self.startHour > self.endHour) || (self.startHour == self.endHour)))
     errors.add([:starHour,:endHour],"Attenzione: l'ora di fine deve essere maggiore dell'ora di inizio")
   end
  end
 end
