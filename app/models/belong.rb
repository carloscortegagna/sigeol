#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: belong.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#13/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura

class Belong < ActiveRecord::Base
 belongs_to :teaching
 belongs_to :curriculum

  #validazioni :teaching_id e :curriculum_id
    validates_presence_of :teaching_id,
                         :message=>"Associzione non valida",
                         :on => :save or :create or :update
    validates_presence_of :curriculum_id,
                         :message=>"Associazione non valida",
                         :on => :save or :create or :update
    validates_presence_of :isOptional,
                         :message=>"Setta se l'insegnamento è opzionale",
                         :on => :save or :create or :update
  #validazione unicità curriculm_id e teaching_id
 private
 validate :unique_curriculum_id_and_teaching_id?
  def unique_curriculum_id_and_teaching_id?
    if Belong.find_by_curriculum_id_and_teaching_id(teaching_id,curriculum_id)
      errors.add_to_base("L'insegnamento è gia assegnato al curriculum")
    end
  end

end