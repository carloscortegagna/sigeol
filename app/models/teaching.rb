#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: teaching.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#13/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura

class Teaching < ActiveRecord::Base
 #associazioni
 belongs_to :teacher
 belongs_to :period
 has_many :belongs
 has_many :curriculums, :through=> :belongs
 has_many :timetable_entries

#Validazioni :name
   validates_presence_of :name,
                         :message=>"Il nome non deve essere vuoto",
                         :on => :save or :create or :update
   validates_length_of :name,
                       :maximum=> 30
   validates_format_of :name,
                       :with => /[a-zA-Z0-9\.\s]/,
                       :message=>"Si accetta solo caratteri numeri e il carattere spazio",
                       :on => :save or :create or :update
  validates_uniqueness_of :name,
                          :message=>"Il nome dell'insegnamento è già presente",
                          :on => :save or :create or :update
  
#validazioni :CFU,:classHours,:labHours,:studentsNumber,
 validates_numericality_of :CFU,
                           :only_integer =>true,
                           :grater_than_or_euqual_to =>1,
                           :less_than_or_equal_to =>20
  
validates_numericality_of :labHours,:classHours,
                           :only_integer =>true,
                           :grater_than_or_euqual_to =>1,
                           :less_than_or_equal_to =>50

 validates_numericality_of :studentsNumber,
                          :only_integer =>true,
                          :grater_than_or_euqual_to =>1,
                          :less_than_or_equal_to =>1000

  end
