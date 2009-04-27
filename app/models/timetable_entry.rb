#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: timetable_entry.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/09
#REGISTRO DELLE MODIFICHE::
# 24/04/09 Approvazione del responsabile
#
# 01/03/09 Aggiunti i metodi is_correct_time? e unique?
#
# 20/02/09 Aggiunta delle prime validazioni
#
# 16/02/09 Prima stesura
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
  validate :unique?
  validate :is_correct_time?
                    

 private

 #Confronta l'orario di fine con quello iniziale della lezione, e se il primo risulta maggiore del secondo,
 #aggiunge un messaggio all'oggetto +errors+, contenente gli errori di validazione.
 def is_correct_time? #:doc:
   if(self.endTime && self.startTime && (self.endTime<=>self.startTime)==-1)
     errors.add([:starTime,:endTime],"Attenzione l'ora di inizio è piu grande dell'ora di fine")
   end
 end

 #Aggiunge all'oggetto +errors+, contentente gli errori di validazioni, un messaggio se essite già un elemento uguale
 #all'oggetto d'invocazione nel database.
  def unique? #:doc:
    t=TimetableEntry.find_by_startTime_and_endTime_and_day_and_timetable_id_and_classroom_id(self.startTime,self.endTime,self.day,self.timetable_id,self.classroom_id)
    if t && t.id!=self.id
     errors.add_to_base("riga già presente")
    end
  end
end
