#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: temporal_constraint.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 16/02/09
#REGISTRO DELLE MODIFICHE:
#13/03/09 Aggiunta validates_numericality_of :isHard
#20/02/09 Aggiunta delle validazioni
#16/02/09 Prima stesura

class TemporalConstraint < ActiveRecord::Base

  validates_numericality_of :isHard,
                          :only_integer => true,
                          :greater_than_or_equal_to => 0,
                          :less_than_or_equal_to => 10,
                          :message => "Deve essere compreso tra 1 e 10"

  #validazioni :startTime e :endTime e validazioni :day
 validates_presence_of :startHour,:endHour,:day,:description,:isHard,
                          :message=>"Alcuni campi sono vuoti"
 validates_numericality_of :day,
                          :only_integer => true,
                          :greater_than_or_equal_to => 1,
                          :less_than_or_equal_to => 5,
                          :message => "Deve essere compreso tra 1 e 5"
                     
  validate :is_correct_time?


 private

 def is_correct_time?
   if(self.startHour && self.endHour && (self.endHour<=>self.startHour)==-1)
     errors.add([:starHour,:endHour],"Attenzione l'ora di inizio è piu grande dell'ora di fine")
   end
 end

 end
