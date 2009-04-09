#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: belong.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 16/02/09
#REGISTRO DELLE MODIFICHE:
#03/03/09 Aggiunta validates_inclusion_of :isOptional
#20/02/09 Aggiunta del metodo after_destroy
#18/02/09 Aggiunta delle validazioni
#16/02/09 Prima stesura

class Belong < ActiveRecord::Base
 belongs_to :teaching
 belongs_to :curriculum

    validates_inclusion_of :isOptional,
                           :in => [true, false],
                           :allow_nil=>false,
                           :message=>"Inserisci un valore per isOptional valido"

  #validazioni :teaching_id e :curriculum_id
    validate_on_create :unique_curriculum_id_and_teaching_id?

    validates_presence_of :curriculum_id,
                          :message => "Associa un curriculum"
    validates_presence_of :teaching_id,
                          :on => :update,
                          :message => "Associa un insegnamento"
  #se l'insegnamento non è legato a nessun curriculum,eliminalo
  def after_destroy
    if(Belong.count(:conditions=>["teaching_id = ?" , self.teaching_id])==0)
      Teaching.destroy(teaching_id)
    end
  end

#  def before_validation
#    self.isOptional = false if !attribute_present?("isOptional")
#  end

  #validazione unicità curriculm_id e teaching_id
 private
  def unique_curriculum_id_and_teaching_id?
    if self.teaching_id
      if Belong.find_by_curriculum_id_and_teaching_id(self.curriculum_id,self.teaching_id)
        errors.add_to_base("L'insegnamento è gia assegnato al curriculum")
      end
    end
  end
end
