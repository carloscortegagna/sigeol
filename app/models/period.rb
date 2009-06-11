#=QuiXoft - Progetto SIGEOL
#NOME FILE:: period.rb
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/2009
#REGISTRO DELLE MODIFICHE::
# 20/04/2009 Approvazione del responsabile
#
# 06/03/2009 Piccole modifiche alle validazioni e alle associazioni
#
# 17/02/2009 Aggiunta delle validazioni
#
# 16/02/2009 Prima stesura
#
#Rappresentazione di un periodo dell'anno accademico, inteso come periodo (primo trimestre, secondo semestre ecc.)
#e anno (primo anno, secondo, anno ecc.).

class Period < ActiveRecord::Base
  has_many :teachings
  has_many :timetables
  #validazioni :subperiod
  validates_numericality_of :subperiod,
                            :only_integer =>true,
                            :greater_than_or_equal_to =>1,
                            :less_than_or_equal_to =>4,
                            :message=>"il sotto periodo deve essere compreso tra 1 e 4"
  
  validates_numericality_of :year,
                            :only_integer =>true,
                            :greater_than_or_equal_to =>1,
                            :less_than_or_equal_to =>6,
                            :message=>"L'anno deve essere compreso tra 1 e 6"
  #validazione unicità subperiod e year
  validate_on_create :unique_subperiod_year?

  private

  #Aggiunge all'oggetto +errors+, contenente gli errori di validazione, un ulteriore errore se
  #è già presente un periodo con anno e sotto-periodo uguale a quelli dell'oggetto d'invocazione.
  def unique_subperiod_year? #:doc:
    if Period.find_by_year_and_subperiod(self.year,self.subperiod)
      errors.add_to_base("Sotto periodo e anno già presenti")
    end
  end


end
