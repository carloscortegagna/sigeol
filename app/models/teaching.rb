#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: teaching.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/09
#REGISTRO DELLE MODIFICHE::
# 22/04/09 Approvazione del responsabile
#
# 28/02/09 Aggiunto il metodo validates_presence_of :period_id,
#
# 24/02/09 Aggiunto il metodo check_durata?
#
# 18/02/09 Aggiunta delle validazioni
#
# 16/02/09 Prima stesura
#
#Rappresentazione di un insegnamento. Contiene informazioni quali il periodo (_Period_) ed il curriculum (_Curriculum_)
#di appartenenza, nonchè il docente (_Teacher_) titolare del corso d'insegnamento.

class Teaching < ActiveRecord::Base
 
 include ApplicationHelper

 has_many :belongs, :dependent => :destroy
 has_many :curriculums, :through => :belongs
 has_many :timetable_entries, :dependent => :destroy
 belongs_to :period
 belongs_to :teacher
  
 validates_presence_of :name,
                       :message => "Il nome non deve essere vuoto"
 validates_presence_of :period_id,
                       :message => "Devi associare un periodo"
 validates_length_of :name,
                     :maximum => 30
 validates_format_of :name,
                     :with => /^[a-zA-Zàòèéùì\s0-9]*$/,
                     :message =>"Si accetta solo caratteri numeri e il carattere spazio"
 
 #validazioni :CFU,:classHours,:labHours,:studentsNumber,
 validates_numericality_of :CFU,
                           :only_integer => true,
                           :greater_than_or_equal_to => 0,
                           :less_than_or_equal_to => 20,
                           :allow_nil=>true,
                           :message=>"Attenzione il numero deve essere compreso tra 0 e 20"

 validates_numericality_of :labHours,:classHours,
                           :only_integer => true,
                           :greater_than_or_equal_to => 0,
                           :less_than_or_equal_to => 50,
                           :allow_nil => true,
                           :message => "Attenzione il numero deve essere compreso tra 0 e 50"

 validates_numericality_of :studentsNumber,
                           :only_integer => true,
                           :greater_than_or_equal_to => 0,
                           :less_than_or_equal_to => 1000,
                           :allow_nil => true,
                           :message => "Attenzione il numero deve essere compreso tra 0 e 1000"
 validates_associated :teacher,
                      :message => "Il teacher associato non è valido"

 validates_presence_of :period_id,
                       :message => "Associa un periodo all'insegnamento"
 validate :check_durata?

 def before_validation
  self.name=first_upper(self.name)
 end

 private

 #Controlla se il periodo assegnato all'oggetto d'invocazione è compatibile con l'organizzazione accademica
 #(_AcademicOrganization_) dei corsi di laurea (_GraduateCourse_) ad esso assegnati. Ad esempio un corso di lauera
 #organizzato a semestri non potrà avere una corso d'insegnamento che si svolve nel terzo periodo in quanto
 #esistono solamente due semestri in un anno accademico.
 def check_durata? #:doc:
  c = self.belongs
  ids = []
  c.each do |k|
    ids << k.curriculum_id
  end
  maxyear = GraduateCourse.minimum("duration", :include => :curriculums,
                                   :conditions => ["curriculums.id IN (?)", ids])
  maxsubperiod = AcademicOrganization.minimum("number", :include => [:graduate_courses => :curriculums],
                                              :conditions => ["curriculums.id IN (?)", ids])
  if (self.period && (self.period.subperiod > maxsubperiod.to_i || self.period.year > maxyear.to_i))
    errors.add(:period, "Non puo assegnare questo periodo a questo insegnamento" + maxyear.to_s + " " + maxsubperiod.to_s)
  end
 end
end

