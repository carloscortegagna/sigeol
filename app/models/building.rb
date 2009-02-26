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

 belongs_to :address, :dependent => :destroy
 has_many :classrooms, :dependent => :destroy
 
  #validazioni :name
  validates_uniqueness_of :name,
                          :message=>"Esiste già un palazzo con questo nome"
  validates_presence_of :name,
                        :message=>"Il nome non deve essere vuoto"
  validates_length_of :name,
                       :maximum=> 30,
                       :message=>"Il nome è troppo lungo"
  validates_format_of :name,
                     :with => /^[a-zA-Z0-9àòèéùì\s]*$/,
                     :message=>"Si accetta solo caratteri"
 #validazione presenza indirizzo
  validates_presence_of :address_id,
                          :message=>"Immetti l'indirizzo del palazzo"
 #validazione associazione 1 a 1
  validate :is_only_my_address?

  def before_save
      self.name=first_upper(self.name)
    end
private
def is_only_my_address?
    if(self.address_id!=nil && (Building.find_by_address_id(self.address_id) != nil || User.find_by_address_id(self.address_id)) != nil)
      errors.add(:address_id, "L'indirizzo associato appartiene ad un'altra entità")
  end
end

end
 

