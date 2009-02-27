#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: classroom.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#17/02/09 Aggiunta delle validazioni
#12/02/09 Prima stesura

class TimetableEntry < ActiveRecord::Base
  belongs_to :timetable
  belongs_to :teaching
  belongs_to :classroom

  #validazioni :startTime e :endTime e validazioni :day

  validates_presence_of :startTime,:endTime,:day,:timetable_id,:classroom_id,
                          :message=>"Alcuni campi sono vuoti"

  validates_inclusion_of :day,
                       :in => 1..5,
                       :message => "Deve essere compreso tra 1 e 5"
  validate :unique?
  validate :is_correct_time?
                    

 private

 def is_correct_time?
   if(self.endTime && self.startTime && (self.endTime<=>self.startTime)==-1)
     errors.add([:starTime,:endTime],"Attenzione l'ora di inizio è piu grande dell'ora di fine")
   end
 end

  def unique?
    if TimetableEntry.find_by_startTime_and_endTime_and_day_and_timetable_id_and_classroom_id(self.startTime,self.endTime,self.day,self.timetable_id,self.classroom_id)
      errors.add_to_base("riga già presente")
    end
  end
end
