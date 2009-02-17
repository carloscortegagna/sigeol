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
  
  #validazioni :startime, :endtime
   validates_presence_of :startime, :endtime,
                         :message=>"Manca l'ora d'inizio o di fine",
                         :on => :save or :create or :update
   

end
