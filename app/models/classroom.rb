#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: classroom.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#17/02/09 Aggiunta delle validazioni
#12/02/09 Prima stesura
class Classroom < ActiveRecord::Base
  include ApplicationHelper
  
  belongs_to :building
  has_many_polymorphs :constraints, :from => [:boolean_constraints, :temporal_constraints],
    :as => :owner,:dependent => :destroy
  has_many :timetable_entries, :dependent => :destroy
  has_and_belongs_to_many :graduate_courses, :uniq => true

  #validazioni :name
  validates_presence_of :name,
                        :message => "Il nome non deve essere vuoto"
  validates_length_of :name,
                      :maximum => 30,
                      :message => "Il nome è troppo lungo"
  validates_format_of :name,
                      :with => /[^a-zA-Z0-9àòèéùì\s$]*/,
                      :message => "Si accetta solo caratteri"

 
#validazioni :capacity
  validates_numericality_of :capacity,
                            :only_integer => true,
                            :grater_than_or_euqual_to => 0,
                            :less_than_or_equal_to => 1000,
                            :allow_nil => true,
                            :message => "Attenzione il numero deve essere compreso tra 0 e 1000"

 #validazione presenza chiave esterna building
validates_presence_of :building_id,
                      :message=>"Deve essere associato ad un palazzo"
                       
 #validazioni unicità palazzo-classe
validate :unique_building_classroom?

 def before_save
      self.name=first_upper(self.name)
    end

  private
 def unique_building_classroom?
   name=first_upper(self.name)
   c=Classroom.find_by_name_and_building_id(name,self.building_id)
   if c && c.id!=self.id
     errors.add_to_base("Nel palazzo è gia presente un'aula con questo nome")
    end
  end


end
