#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: classroom.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/09
#REGISTRO DELLE MODIFICHE::
# 28/04/09 Approvazione del responsabile
#
# 10/03/09 Aggiunta dell'associazione polimorfa has_many :constraints
#
# 22/02/09 Piccola correzione all'espressione regolare che valida il nome dell'aula
#
# 17/02/09 Aggiunta delle validazioni e dell'associazione polimorfa
#
# 16/02/09 Prima stesura
#
#Rappresentazione di un aula. Ad essa possono essere associati dei vincoli, degli elementi di una
#tabella oraria (_Timetable_entry_), almeno un corso di laurea(_Graduate_course_) ed un solo
#edificio(_Building_).

class Classroom < ActiveRecord::Base
  include ApplicationHelper
  
  has_many :constraints, :dependent=> :destroy
  belongs_to :building
  has_many :timetable_entries, :dependent => :destroy
  has_and_belongs_to_many :graduate_courses, :uniq => true

  #validazioni :name
  validates_presence_of :name,
                        :message => "Il nome non deve essere vuoto"
  validates_length_of :name,
                      :maximum => 30,
                      :message => "Il nome è troppo lungo"
                    
  #validazioni :capacity
  validates_numericality_of :capacity,
                            :only_integer => true,
                            :greater_than_or_equal_to => 1,
                            :less_than_or_equal_to => 1000,
                            :allow_nil => true,
                            :message => "Attenzione il numero deve essere compreso tra 1 e 1000"

  #validazione presenza chiave esterna building
  validates_presence_of :building_id,
                      :message=>"Deve essere associato ad un palazzo"
                       
  #validazioni unicità palazzo-classe
  validate :unique_building_classroom?

  private
  
  #Se esiste già un'aula uguale a quella di invocazione associata allo stesso edificio,
  #viene aggiunto all'oggetto +errors+, contenente gli errori di validazione, un ulteriore messaggio.
  def unique_building_classroom? #:doc:
    c=Classroom.find_by_name_and_building_id(self.name,self.building_id)
    if c && c.id!=self.id
      errors.add(:name,"Nell'edificio è gia presente un'aula con questo nome")
    end
  end
end