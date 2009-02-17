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
   validates_uniqueness_of :name,
                          :message=>"Il nome è già presente",
                          :on => :save or :create or :update

   validates_presence_of :name,
                         :message=>"Il nome non deve essere vuoto",
                         :on => :save or :create or :update
   validates_length_of :name,
                       :maximum=> 30,
                       :message=>"Il nome è troppo lungo",
                       :on => :save or :create or :update
   validates_format_of :name,
                     :with => /[a-zA-Zàòèéùì]*/,
                     :message=>"Si accetta solo caratteri",
                     :on => :save or :create or :update
 #funzione di callback,mette tutto in minuscolo del nome, tranne la prima lettera
 #si utilizza la funzione first_upper presente sul modulo ApplicationHelper
 def before_save
   self.name=first_upper(self.name)
 end
  #validazioni :number
  validates_uniqueness_of :number,
                          :message=>"E' gia presente un'organizzazione con questo valore",
                          :on => :save or :create or :update

  validates_numericality_of :number,
                           :only_integer =>true,
                           :grater_than_or_euqual_to =>1,
                           :less_than_or_equal_to =>6,
                           :message=>"attenzione il numero deve essere compreso tra 1 e 6"

  validates_presence_of  :number,
                         :message=>"Il numero di periodi non deve essere vuoto",
                         :on => :save or :create or :update
 
end

