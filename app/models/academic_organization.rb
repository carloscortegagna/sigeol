#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: academic_organization.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/09
#REGISTRO DELLE MODIFICHE::
# 20/04/09 Approvazione del responsabile
#
# 26/02/09 Aggiunta validates_uniqueness_of :name
#
# 18/02/09 Aggiunta validates_numericality_of :number
#
# 16/02/09 Prima stesura
#
#Rappresentazione dell'organizzazione accademica di un corso di laurea. Al momento dell'installazione
#del sistema sono presenti le organizzazioni "Semestrale", "Trimestrale" e "Bimestrale".

class AcademicOrganization < ActiveRecord::Base
  include ApplicationHelper
  
  has_many :graduate_courses

  #validazioni :name
  validates_uniqueness_of :name,
                          :message => "E' gia presente un organizzazione accademica con questo nome"
                          
  validates_presence_of :name,
                        :message => "Il nome non deve essere vuoto"
                         
  validates_length_of :name,
                      :maximum => 30,
                      :message => "Il nome è troppo lungo"

  validates_format_of :name,
                      :with => /^[a-zA-Zàòèéùì\s]*$/,
                      :message => "Si accetta solo caratteri"
  #validazioni :number
  validates_uniqueness_of :number,
                          :message => "E' gia presente un organizzazione accademica con questo numero"
  validates_numericality_of :number,
                            :only_integer => true,
                            :greater_than_or_equal_to => 1,
                            :less_than_or_equal_to => 4,
                            :message => "Il numero deve essere compreso tra 1 e 4"

  validates_presence_of  :number,
                         :message => "Il numero di periodi non deve essere vuoto"

  #Override del metodo della super classe per impostare il primo carattere del nome in maiusculo
  #ed i rimanenti in minuscolo, prima delle validazioni.
  def before_validation
    self.name=first_upper(self.name)
  end
end
