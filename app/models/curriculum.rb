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
 has_many :belongs
 has_many :teachings, :through=>:belongs,:dependent=> :destroy

#validazioni :name
  validates_uniqueness_of :name,
                          :message=>"Il curriculum è già presente",
                          :on => :save or :create or :update

  validates_presence_of :name,
                         :message=>"Il nome non deve essere vuoto",
                         :on => :save or :create or :update
   validates_length_of :name,
                       :maximum=> 50,
                       :message=>"Il nome è troppo lungo",
                       :on => :save or :create or :update
   validates_format_of :name,
                     :with => /[a-zA-Zàòèéùì]*/,
                     :message=>"Si accetta solo caratteri",
                     :on => :save or :create or :update
   #funzione di callback,mette tutto in minuscolo del nome, tranne la prima lettera
 def before_save
   self.name=first_upper(self.name)
 end


  #validazioni :graduate_course_id
 validates_presence_of :graduate_course_id,
                         :message=>"Il curriculum deve essere associato ad un corso di laurea",
                         :on => :save or :create or :update
end
