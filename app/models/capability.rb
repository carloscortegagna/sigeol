#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: capability.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#17/02/09 Aggiunta delle validazioni
#12/02/09 Prima stesura
class Capability < ActiveRecord::Base
 has_and_belongs_to_many :users, :uniq => true

  #validazioni :name
   validates_presence_of :name,
                         :message => "Il nome non deve essere vuoto"
   validates_length_of :name,
                       :maximum => 30,
                       :message => "Il nome è troppo lungo"
   validates_format_of :name,
                     :with => /[^a-zA-Z0-9àòèéùì\s$]*/,
                     :message =>"Si accetta solo caratteri"
  validates_uniqueness_of :name,
                          :message => "La capability è già presente"

end
