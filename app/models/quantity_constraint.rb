class QuantityConstraint < ActiveRecord::Base

  #validazioni :quantity
  validates_numericality_of :quantity,
                           :only_integer =>true,
                           :grater_than_or_euqual_to =>1,
                           :less_than_or_equal_to =>1000,
                           :message=>"attenzione il numero deve essere compreso tra 1 e 1000"

  validates_presence_of  :quantity,
                         :message=>"La durata non deve essere vuota"

end
