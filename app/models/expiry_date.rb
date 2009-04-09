#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: expiry_date.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 16/02/09
#REGISTRO DELLE MODIFICHE:
#28/02/09  Aggiunta nel metodo correct_date dell'istruzione self.date.to_date
#27/02/09 Aggiunta del metodo is_correct_date?
#14/02/09 Aggiunta delle validazioni
#16/02/09 Prima stesura

class ExpiryDate < ActiveRecord::Base
  belongs_to :graduate_course

 validates_presence_of :period,
                         :message=>"Inserisci il periodo associato alla data"

  validates_numericality_of :period,
                            :only_integer =>true,
                            :greater_than_or_equal_to =>1,
                            :less_than_or_equal_to =>10,
                            :message=>"Attenzione il periodo deve essere compreso tra 1 e 10"

  validates_presence_of :date,
                        :message=>"La data non deve essere vuota"

  validates_presence_of  :graduate_course_id,
                        :message=>"Deve essere associata ad un corso di laurea"

  validate :is_correct_date?
  private
    def is_correct_date?
      if self.date
        self.date.to_date;
        if self.date.past?
         errors.add(:date,"La data deve essere maggiore di quella di oggi(#{::Date.current}).")
      end
    end
  end
  end