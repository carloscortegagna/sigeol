#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: timetable.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/09
#REGISTRO DELLE MODIFICHE::
# 27/04/09 Approvazione del responsabile
#
# 10/03/09 Modifica del metodo validates_inclusion_of :isPublic e aggiunta del metodo correct_year
#
# 20/02/09 Aggiunta delle validazioni
#
# 16/02/09 Prima stesura
#
#Rappresentazione della tabella oraria. Comprende il corso di laurea di appartenenza, il periodo di competenza
#e l'anno accademico di riferimento.

class Timetable < ActiveRecord::Base
  belongs_to :period
  belongs_to :graduate_course
  has_many :timetable_entries, :dependent=>:destroy

  #validazioni :isPublic
  validates_inclusion_of :isPublic, 
                         :in => [true, false], 
                         :allow_nil=>false,
                         :message=>"Inserisci un valore per isPublic valido"
  # validazioni :year
  validates_presence_of :year,:period_id,:graduate_course_id,
                        :message => "Aggiungi l'anno accademico o il periodo o il corso di laurea"

  validates_format_of :year,
                     :with => /^[0-9]{4,4}\/[0-9]{2,2}$/,
                     :message => "deve essere scritto nella forma aaaa/aa"

  validate :correct_year
  validate :unique?

  private

  #Aggiunge all'oggetto +errors+, contentente gli errori di validazioni, un messaggio se essite già un elemento uguale
  #all'oggetto d'invocazione nel database.
  def unique? #:doc:
    t=Timetable.find_by_period_id_and_graduate_course_id_and_year(self.period_id,self.graduate_course_id,self.year)
    if t && t.id!=self.id
      errors.add_to_base("riga già presente")
    end
  end

  #CONTROLLARE QUESTO METODO.
  def correct_year #:doc:
   if year
    year=self.year[0..3].to_i
    this_year=::Date.current.year.to_i
    sub_year=self.year[2..3].to_i
    sub_year1=self.year[5..6].to_i
    if((year<(this_year-1))||(sub_year!=(sub_year1-1)))
      errors.add(:year,"L'anno inserito non è corretto")
    end
   end
  end
end

