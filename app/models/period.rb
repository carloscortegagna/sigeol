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
  validates_inclusion_of :subperiod,
                         :in  =>1..4,
                         :message=>"Il sotto-periodo deve essere compreso tra 1 e 4",
                         :on=> :save or :create or :update

 #validazioni :year
  validates_inclusion_of :year,
                         :in  =>1..6,
                         :message=>"L'anno deve essere compreso tra 1 e 6",
                         :on=> :save or :create or :update

 #validazione unicità subperiod e year
 private
 validate :unique_subperiod_year?
  def unique_subperiod_year?
    if Period.find_by_year_and_subperiod(year,subperiod)
      errors.add_to_base("sotto periodo e anno già presenti")
    end
  end

end
