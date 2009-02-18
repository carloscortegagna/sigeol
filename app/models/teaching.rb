#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: teaching.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#13/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura

class Teaching < ActiveRecord::Base
include ApplicationHelper
 #associazioni
 belongs_to :teacher
 belongs_to :period
 has_many :belongs
 has_many :curriculums, :through=> :belongs
 has_many :timetable_entries

#Validazioni :name
   validates_presence_of :name,
                         :message=>"Il nome non deve essere vuoto"
   validates_length_of :name,
                       :maximum=> 30
   validates_format_of :name,
                       :with => /[a-zA-Zàòèéùì]*/,
                       :message=>"Si accetta solo caratteri numeri e il carattere spazio"
  validates_uniqueness_of :name,
                          :message=>"Il nome dell'insegnamento è già presente"

  #funzione di callback,mette tutto in minuscolo del nome, tranne la prima lettera
  def before_save
    self.name=first_upper(self.name)
 end
 
  #validazioni :CFU,:classHours,:labHours,:studentsNumber,
 validates_numericality_of :CFU,
                           :only_integer =>true,
                           :grater_than_or_euqual_to =>0,
                           :less_than_or_equal_to =>20,
                           :allow_nil=>true,
                           :message=>"Attenzione il numero deve essere compreso tra 0 e 20"

validates_numericality_of :labHours,:classHours,
                           :only_integer =>true,
                           :grater_than_or_euqual_to =>0,
                           :less_than_or_equal_to =>50,
                           :allow_nil=>true,
                           :message=>"Attenzione il numero deve essere compreso tra 0 e 50"

 validates_numericality_of :studentsNumber,
                          :only_integer =>true,
                          :grater_than_or_euqual_to =>0,
                          :less_than_or_equal_to =>1000,
                          :allow_nil=>true,
                          :message=>"Attenzione il numero deve essere compreso tra 0 e 1000"

  validate :check_durata?
private
 #si valida sse all'insegnamento è associato un corso di laurea ed un periodo
#un corso di laurea deve obbligatoriamente avere un'organizzazione
  def check_durata?
  b=Belong.find_by_teaching_id(id)
  if(b && period_id)
#si individua il numero di periodi e la durata del corso di laurea associato
#all'insegnamento
   find_graduate_course_organization(b)
#si individua il periodo e l'anno assegnato all'insegnamento
   find_period(period_id)
    if(@sotto_periodo>@periodi_corso)
     errors.add_to_base("Il corso di laurea ha #{@periodi_corso}. Si è inserito #{@periodo}")
   end
   if(@anno>@durata_corso)
      errors.add_to_base("Il corso di laurea dura #{@durata_corso}. Si è inserito #{@anno}")
   end
  end

end

  def find_graduate_course_organization(b)
    #Se esiste l'associzione esisterà per forza il curriculum associato
    #e non sarà mai nil
    curriculum=Curriculum.find_by_id(b.curriculum_id)
    #un curriculum se esiste è associato ad un corso di laurea
    corso_di_laurea=GraduateCourse.find_by_id(curriculum.graduate_course_id)
    #un corso se esiste ha un organizzazione
    organizzazione_id=corso_di_laurea.academic_organization_id
    organizzazione=AcademicOrganization.find_by_id(organizzazione_id)
    #un organizzazione ha necessariamente gli attributi number e duration non nulli
    @periodi_corso=organizzazione.number
    @durata_corso=corso_di_laurea.duration
  end

  def find_period(id)
    #un periodo ha necessariamente il suo attributo subperiod e il suo year non mulli
    periodo=Period.find_by_id(id)
    @sotto_periodo=periodo.subperiod
    @anno=periodo.year
    
  end
end

