#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: expiry_date.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#14/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura
class ExpiryDate < ActiveRecord::Base

  belongs_to :graduate_course

  validates_presence_of :date,
                        :message=>"La data non deve essere vuota"
  validates_presence_of :graduate_course_id,
                        :message=>"Deve essere associata ad un corso di laurea"
  validate :is_correct_date?
  private
    def is_correct_date?
      if self.date && self.date.past?
        errors.add(:date,"La data deve essere maggiore di quella di oggi(#{::Date.current}).")
      end
    end
  end