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
    validates_presence_of :isOptional,
                         :message=>"Setta se l'insegnamento è opzionale"

  #se l'insegnamento non è legato a nessun curriculum,eliminalo
  def after_destroy
    if(Belong.count(:conditions=>["teaching_id = ?" , teaching_id])==1)
      Teaching.destroy(teaching_id)
    end
  end

  #validazione unicità curriculm_id e teaching_id
 private
 validate :unique_curriculum_id_and_teaching_id?
  def unique_curriculum_id_and_teaching_id?
    if Belong.find_by_curriculum_id_and_teaching_id(teaching_id,curriculum_id)
      errors.add_to_base("L'insegnamento è gia assegnato al curriculum")
    end
  end

  end