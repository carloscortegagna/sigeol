#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: didactic_office.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#15/02/09 
#12/02/09 Prima stesura
class DidacticOffice < ActiveRecord::Base
  has_one :user, :as => :specified

  def before_destroy
   u=User.find_by_specified_id_and_specified_type(self.id,"DidacticOffice")
   u.delete
  end

end
