#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: period.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#14/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura

class Period < ActiveRecord::Base
  has_many :teachings
  has_many :timetable
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
  def unique_subperiod_year?
    if Period.find_by_year_and_subperiod(self.year,self.subperiod)
      errors.add_to_base("Sotto periodo e anno già presenti")
    end
  end


end
