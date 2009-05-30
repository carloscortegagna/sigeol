# QuiXoft - Progetto ”SIGEOL”
# NOME FILE:: teaching.rb
# AUTORE:: Grosselle Alessandro
# DATA CREAZIONE:: 16/02/2009
#
# REGISTRO DELLE MODIFICHE:
#
# 22/04/2009 Approvazione del responsabile
#
# 28/02/2009 Aggiunto il metodo validates_presence_of :period_id,
#
# 24/02/2009 Aggiunto il metodo check_durata?
#
# 18/02/2009 Aggiunta delle validazioni
#
# 16/02/2009 Prima stesura


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
                     :maximum => 30,
                     :message => "Il nome è troppo lungo. Massimo 30 caratteri"
 validates_format_of :name,
                     :with => /^[a-zA-Zàòèéùì\s0-9]*$/,
                     :message =>"Si accettano solo caratteri alfanumerici e il carattere spazio"
 
 #validazioni :CFU,:classHours,:labHours,:studentsNumber,
 validates_numericality_of :CFU,
                           :only_integer => true,
                           :greater_than_or_equal_to => 0,
                           :less_than_or_equal_to => 20,
                           :allow_nil=>true,
                           :message=>"Il numero deve essere compreso tra 0 e 20"

 validates_numericality_of :labHours,:classHours,
                           :only_integer => true,
                           :greater_than_or_equal_to => 0,
                           :less_than_or_equal_to => 50,
                           :allow_nil => true,
                           :message => "Il numero deve essere compreso tra 0 e 50"

 validates_numericality_of :studentsNumber,
                           :only_integer => true,
                           :greater_than_or_equal_to => 0,
                           :less_than_or_equal_to => 1000,
                           :allow_nil => true,
                           :message => "Il numero deve essere compreso tra 0 e 1000"
 validates_associated :teacher,
                      :message => "Il teacher associato non è valido"

 validates_presence_of :period_id,
                       :message => "Associa un periodo all'insegnamento"
 validate :check_durata?

 #Override del metodo della super classe per impostare il primo carattere del nome in maiusculo
 #ed i rimanenti in minuscolo, prima delle validazioni.
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
    errors.add(:period, "Non puoi assegnare questo periodo a questo insegnamento" + maxyear.to_s + " " + maxsubperiod.to_s)
  end
 end
end

