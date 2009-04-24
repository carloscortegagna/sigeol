################################################################################
#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: quantity_constraint.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 16/02/09
#REGISTRO DELLE MODIFICHE:
#13/03/09 Aggiunta validates_numericality_of :isHard
#20/02/09 Aggiunta delle validazioni
#16/02/09 Prima stesura
################################################################################

class QuantityConstraint < ActiveRecord::Base

 validates_numericality_of :isHard,
                           :only_integer =>true,
                           :greater_than_or_equal_to =>0,
                           :less_than_or_equal_to =>10,
                           :message=>"attenzione il numero deve essere compreso tra 0 e 10"

  #validazioni :quantity
  validates_numericality_of :quantity,
                           :only_integer =>true,
                           :greater_than_or_equal_to =>1,
                           :less_than_or_equal_to =>1000,
                           :message=>"attenzione il numero deve essere compreso tra 1 e 1000"

  validates_presence_of  :quantity,:description,:isHard,
                         :message=>"La durata non deve essere vuota"

end
