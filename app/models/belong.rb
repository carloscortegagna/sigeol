#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: belong.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/09
#REGISTRO DELLE MODIFICHE::
# 28/04/09 Approvazione del responsabile
#
# 03/03/09 Aggiunta validates_inclusion_of :isOptional
#
# 20/02/09 Aggiunta del metodo after_destroy
#
# 18/02/09 Aggiunta delle validazioni
#
# 16/02/09 Prima stesura
#
#Rappresentazione dell'associazione tra insegnamenti(_Teaching_) e curricula (_Curriculum_).

class Belong < ActiveRecord::Base
 belongs_to :teaching
 belongs_to :curriculum

 validates_inclusion_of :isOptional,
                        :in => [true, false],
                        :allow_nil=>false,
                        :message=>"Inserisci un valore per isOptional valido"

  #validazioni :teaching_id e :curriculum_id
  validate :unique_curriculum_id_and_teaching_id?

  validates_presence_of :curriculum_id,
                        :message => "Associa un curriculum"
  validates_presence_of :teaching_id,
                        :on => :update,
                        :message => "Associa un insegnamento"
  
  #Override del metodo della super classe per eliminare un eventuale insegnamento che non
  #è più associato a nessun curricula, dopo l'eliminazione di un oggetto di tipo _Belong_.
  def after_destroy
    if(Belong.count(:conditions=>["teaching_id = ?" , self.teaching_id])==0)
      Teaching.destroy(teaching_id)
    end
  end

 private

 #Se esiste già uninsegnamento uguale a quello di invocazione associato allo stesso curriculum,
 #viene aggiunto all'oggetto +errors+, contenente gli errori di validazione, un ulteriore messaggio.
 def unique_curriculum_id_and_teaching_id?
  b=Belong.find_by_curriculum_id_and_teaching_id(self.curriculum_id,self.teaching_id)
  if self.teaching_id
    if b && b.id!=self.id
      errors.add_to_base("L'insegnamento è gia assegnato al curriculum")
    end
  end
 end
end