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
  #validazioni associazione
    validates_existence_of :timetable, 
                           :message=>"Il timetable non è valido"
     validates_existence_of :teaching,
                           :message=>"L'insegnamento non è valido"
     validates_existence_of :classroom,
                           :message=>"La classe non è validi"
  #validazioni :startTime e :endTime e validazioni :day

  validates_presence_of :startTime,:endTime,:day,
                          :message=>"Alcuni campi sono vuoti"
  validates_time :startTime,:endTime,
                 :invalid_time_message=>"La data deve essere del tipo h:nn"
  validates_inclusion_of :day,
                       :in => %w{ lun mar mer gio ven sab dom},
                       :message => "Deve essere lun,mar,mer,gio,ven,sab"
  #validazione unicità :startTime :endTime :day :classroom_id time :timetable_id
 private
 validate :unique?
  def unique?
    if TimetableEntry.find_by_startTime_and_endTime_and_day_and_timetable_id_and_classroom_id(startTime,endTime,day,timetable_id,classroom_id)
      errors.add_to_base("riga già presente")
    end
  end
   

end
