#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: teacher.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#15/02/09
#13/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura

class Teacher < ActiveRecord::Base
  include ApplicationHelper
  
  has_one :user, :as => :specified
  has_many :teachings
  #validazioni attributo :name e :surname
   validates_presence_of :name, :surname,
                         :message=>"Il nome non deve essere vuoto",
                         :on => :update
   validates_length_of :name,:surname,
                       :maximum=> 30,
                       :message=>"Il nome è troppo lungo",
                       :on => :update
   validates_format_of :name,:surname,
                     :with => /^[a-zA-Zàòèéùì\s]*$/,
                     :message=>"Si accetta solo caratteri",
                     :on => :update
  #funzione di callback,mette tutto in minuscolo del nome, tranne la prima lettera
 def before_validation
   self.name=first_upper(self.name)
   self.surname=first_upper(self.surname)
 end

 def before_destroy
    u=User.find_by_specified_id_and_specified_type(self.id,"Teacher")
   u.delete
  end

 def complete_name
   self.surname + " " + self.name
 end
end