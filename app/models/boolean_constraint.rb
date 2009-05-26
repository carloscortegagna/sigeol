# QuiXoft - Progetto ”SIGEOL”
# NOME FILE: boolean_constraint.rb
# AUTORE: Grosselle Alessandro
# DATA CREAZIONE: 16/02/2009
#
# REGISTRO DELLE MODIFICHE:
#
# 13/03/2009 validates_numericality_of :isHard
#
# 20/02/2009 Aggiunta delle validazioni
# 
# 16/02/2009 Prima stesura

class BooleanConstraint < ActiveRecord::Base
  has_many :owners
  #validazioni boolean
  validates_inclusion_of :bool,
                         :in => [true, false],
                         :allow_nil=>false,
                         :message=>"Inserisci un valore per bool valido"
 validates_presence_of :description,:isHard,
                      :message=>"Almeno un campo è vuoti"

  validates_numericality_of :isHard,
                           :only_integer =>true,
                           :greater_than_or_equal_to =>0,
                           :less_than_or_equal_to =>10,
                           :message=>"attenzione il numero deve essere compreso tra 0 e 10"
end
