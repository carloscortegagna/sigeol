#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: curriculum.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 12/02/09
#REGISTRO DELLE MODIFICHE::
# 29/04/09 Approvazione del responsabile
#
# 14/03/09 Aggiunto il metodo delete_last_teaching
#
# 22/02/09 name accetta anche il carattere spazio
#
# 18/02/09 Aggiunta delle validazioni
#
# 16/02/09 Prima stesura
#
#Rappresentazione di un curriculum. Se un corso di laurea prevede un solo curriculum, questo conterrà
#nel campo +name+ il valore "Unico".

class Curriculum < ActiveRecord::Base
  include ApplicationHelper

 belongs_to :graduate_course
 has_many :belongs,:dependent => :destroy
 has_many :teachings, :through =>:belongs, :after_remove => :delete_last_teaching

  validates_associated :teachings,
                       :message=>"L'insegnamento non può essere associato a questo curriculum"
  #validazioni :name
  validates_presence_of :name,
                        :message => "Il nome non deve essere vuoto"
  validates_length_of :name,
                      :maximum => 50,
                      :message => "Il nome è troppo lungo"
  validates_format_of :name,
                      :with => /^[a-zA-Zàòèéùì\s]*$/,
                      :message =>"Si accetta solo caratteri"
  validates_presence_of :graduate_course_id,
                        :message => "Deve essere associato ad un corso di laurea"

  #Override del metodo della super classe per impostare il primo carattere del nome in maiusculo
  #ed i rimanenti in minuscolo, prima delle validazioni.
  def before_validation
    self.name=first_upper(self.name)
  end

  #validazioni unicità curriculum-graduate_course
  validate :unique_curriculum_graduate_course?

  private
  
  #Se esiste già un curriculum uguale a quello di invocazione associato allo stesso corso di laurea,
  #viene aggiunto all'oggetto +errors+, contenente gli errori di validazione, un ulteriore messaggio.
  def unique_curriculum_graduate_course?
    c=Curriculum.find_by_name_and_graduate_course_id(self.name,self.graduate_course_id)
    if c && c.id!=self.id
      errors.add(:name,"E' gia presente un curriculum con questo nome")
    end
  end

  #Utilizzato dopo l'eliminazione di un curriculum, per rimuovere eventuali insegnamenti che non risultano
  #associati a nessun altro curriculum.
  def delete_last_teaching(teaching)
    if (teaching.curriculums.size == 0)
      teaching.delete
    end
  end
end
