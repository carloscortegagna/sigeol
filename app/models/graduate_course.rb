#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: graduate_course.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#14/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura

class GraduateCourse < ActiveRecord::Base
  include ApplicationHelper
  has_many :expiry_dates, :dependent=>:destroy
  belongs_to :academic_organization
  has_many :timetables, :dependent=> :destroy
  has_many :curriculums, :dependent=> :destroy
  has_many_polymorphs :constraints, :from => [:quantity_constraints,:boolean_constraints, :temporal_constraints],
    :as=> :owner, :dependent=> :destroy

  validates_existence_of :academic_organization
  #validates_associated :academic_organization
  #validazioni :name
  validates_uniqueness_of :name,
                          :message=>"Il corso è già presente"

  validates_presence_of :name,
                         :message=>"Il nome non deve essere vuoto"
   validates_length_of :name,
                       :maximum=> 50,
                       :message=>"Il nome è troppo lungo"
   validates_format_of :name,
                     :with => /[a-zA-Zàòèéùì]*/,
                     :message=>"Si accetta solo caratteri"
#funzione di callback,mette tutto in minuscolo del nome, tranne la prima lettera
  def before_save
   self.name=first_upper(self.name)
  end


  #validazioni :duration
  validates_numericality_of :duration,
                           :only_integer =>true,
                           :grater_than_or_euqual_to =>1,
                           :less_than_or_equal_to =>6,
                           :message=>"attenzione il numero deve essere compreso tra 1 e 6"

  validates_presence_of  :duration,
                         :message=>"La durata non deve essere vuota",
                         :on => :save or :create or :update

  #validazioni :academic_organization

  validates_presence_of  :academic_organization_id,
                         :message=>"Il corso di laurea deve avere un organizzazione accademica",
                         :on => :save or :create or :update

end
