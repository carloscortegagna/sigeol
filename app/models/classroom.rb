#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: classroom.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#17/02/09 Aggiunta delle validazioni
#12/02/09 Prima stesura
class Classroom < ActiveRecord::Base
  belongs_to :building
  has_many_polymorphs :constraints, :from=>[:boolean_constraints, :temporal_constraints],
    :as=> :owner,:dependent=>:destroy
  has_many :timetable_entries, :dependent=>:destroy

  #validazioni :name
  validates_presence_of :name,
                         :message=>"Il nome non deve essere vuoto"
  validates_length_of :name,
                       :maximum=> 30,
                       :message=>"Il nome è troppo lungo"
  validates_format_of :name,
                     :with => /[^a-zA-Z0-9àòèéùì\s$]*/,
                     :message=>"Si accetta solo caratteri"

 
#validazioni :capacity
  validates_numericality_of :capacity,
                           :only_integer =>true,
                           :grater_than_or_euqual_to =>0,
                           :less_than_or_equal_to =>1000,
                           :allow_nil=>true,
                           :message=>"attenzione il numero deve essere compreso tra 0 e 1000"

#validazioni unicità palazzo-classe
   private
 validate :unique_building_classroom?
  def unique_building_classroom?
    if Classroom.find_by_name_and_building_id(name,building_id)
      errors.add_to_base("Nel palazzo è gia presente un'aula con questo nome")
    end
  end



end
