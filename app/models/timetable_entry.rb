#=QuiXoft - Progetto SIGEOL
#NOME FILE:: timetable_entry.rb
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/2009
#REGISTRO DELLE MODIFICHE::
# 24/04/2009 Approvazione del responsabile
#
# 01/03/2009 Aggiunti i metodi is_correct_time? e unique?
#
# 20/02/2009 Aggiunta delle prime validazioni
#
# 16/02/2009 Prima stesura
#
#Rappresentazione di un elemento della tabella oraria. Esso comprendete l'ora di inizio,
#l'ora finale, il giorno, l'aula, e l'insegnamento di una specifica lezione.

class TimetableEntry < ActiveRecord::Base
  belongs_to :timetable
  belongs_to :teaching
  belongs_to :classroom

  #validazioni :startTime e :endTime e validazioni :day

  validates_presence_of :startTime,:endTime,:day,:timetable_id,:classroom_id,:teaching_id,
                          :message=>"Alcuni campi sono vuoti"

   validates_numericality_of :day,
                          :only_integer => true,
                          :greater_than_or_equal_to => 1,
                          :less_than_or_equal_to => 5,
                          :message => "Attenzione il numero deve essere compreso tra 0 e 1000"
  validate :is_correct_time?
                    

 private

 #Confronta l'orario di fine con quello iniziale della lezione, e se il primo risulta maggiore del secondo,
 #aggiunge un messaggio all'oggetto +errors+, contenente gli errori di validazione.
 def is_correct_time? #:doc:
   if(self.endTime && self.startTime && (self.endTime<=>self.startTime)==-1)
     errors.add([:starTime,:endTime],"Attenzione l'ora di inizio è piu grande dell'ora di fine")
   end
 end
end
