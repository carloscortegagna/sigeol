#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: building.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#17/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura

class Building < ActiveRecord::Base
 include ApplicationHelper
 belongs_to :address, :dependent=>:destroy
 has_many :classrooms, :dependent=>:destroy

  #validazioni :name
  validates_presence_of :name,
                         :message=>"Il nome non deve essere vuoto"
   validates_length_of :name,
                       :maximum=> 30,
                       :message=>"Il nome è troppo lungo"
   validates_format_of :name,
                     :with => /[a-zA-Z0-9àòèéùì]*/,
                     :message=>"Si accetta solo caratteri"
 def before_save
   self.name=first_upper(self.name)
end


end

