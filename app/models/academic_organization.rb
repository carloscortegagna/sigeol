#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: academic_organization.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#14/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura

class AcademicOrganization < ActiveRecord::Base
  include ApplicationHelper
  
  has_many :graduate_courses

#validazioni :name
   validate :is_unique_name?
                          
   validates_presence_of :name,
                         :message => "Il nome non deve essere vuoto"
                         
   validates_length_of :name,
                       :maximum => 30,
                       :message => "Il nome è troppo lungo"

   validates_format_of :name,
                     :with => /^[a-zA-Zàòèéùì\s]*$/,
                     :message => "Si accetta solo caratteri"

  #funzione di callback,mette tutto in minuscolo del nome, tranne la prima lettera
 #si utilizza la funzione first_upper presente sul modulo ApplicationHelper
 def before_save
   self.name=first_upper(self.name)
 end

 #validazioni :number
 validates_uniqueness_of :number,
                         :message => "Il numero è gia presente"
 validates_numericality_of :number,
                           :only_integer => true,
                           :grater_than_or_euqual_to => 1,
                           :less_than_or_equal_to => 6,
                           :message => "Il numero deve essere compreso tra 1 e 6"

  validates_presence_of  :number,
                         :message => "Il numero di periodi non deve essere vuoto"

private
 def is_unique_name?
   name=first_upper(self.name)
   a=AcademicOrganization.find_by_name(name)
   if  a && self.id!=a.id
      errors.add(:name,"E' gia presente un organizzazione accademica con questo nome")
  end
end
end
