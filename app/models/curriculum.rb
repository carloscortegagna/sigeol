#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: curriculum.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#14/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura
class Curriculum < ActiveRecord::Base
  include ApplicationHelper

 belongs_to :graduate_course
 has_many :belongs,:dependent => :destroy
 has_many :teachings, :through =>:belongs

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

  #funzione di callback,mette tutto in minuscolo del nome, tranne la prima lettera
 def before_save
   self.name=first_upper(self.name)
 end

#validazioni unicità curriculum-graduate_course
validate :unique_curriculum_graduate_course?

  private
  def unique_curriculum_graduate_course?
    name=first_upper(self.name)
    c=Curriculum.find_by_name_and_graduate_course_id(name,self.graduate_course_id)
    if c && c.id!=self.id
      errors.add_to_base("E' gia presente un curriculum con questo nome")
    end
  end

end
