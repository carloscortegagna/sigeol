#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: expiry_date_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class ExpiryDateTest < ActiveSupport::TestCase
  def setup
    @e= ExpiryDate.new()
  end
  
  #test26: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
   # nel database
  test"Il contenuto degli attributi non deve essere nullo"do
    #caso di prova26.1: @e ha tutti gli attributi nulli
    #obiettivo: il sistema deve riconoscere @e come oggetto non valido; in particolare deve 
      #essere segnalato un errore in ogni attributo
    assert !@e.valid?
    assert_equal "La data non deve essere vuota", @e.errors.on(:date)
    assert_equal "Deve essere associata ad un corso di laurea", @e.errors.on(:graduate_course_id)
    assert_equal "Inserisci il periodo associato alla data", @e.errors.on(:period).first
  end

  #test27: l'attributo date deve essere maggiore od uguale alla data di sistema
  test"date per essere valido deve rispettare un insieme di regole"do
    #caso di prova27.1: date contiene una data precedente alla data di sistema
    #obiettivo: il sistema deve riconoscere @e come un oggetto non valido; in particolare deve essere
      #segnalato un errore in date
    @e.graduate_course=graduate_courses(:graduate_course_1)
    @e.date=Date.new(12/12/2008)
    assert !@e.valid?
    assert_equal "La data deve essere maggiore di quella di oggi(#{::Date.current})." , @e.errors.on(:date)
  end

  #test28: l'attributo period deve contenere un intero compreso tra uno e quattro
  test"period per essere valido deve rispettare un insieme di regole"do
    #caso di prova28.1: period contiene un valore decimale
    #obiettivo: period contiene un valore non valido e quindi @e deve essere non valido
    @e.period=1.1
    assert !@e.valid?
    assert @e.errors.invalid?(:period)
    #caso di prova28.2: period contiene un valore intero negativo
    #obiettivo: period contiene un valore non valido e quindi @e deve essere non valido
    @e.period=-1
    assert !@e.valid?
    assert @e.errors.invalid?(:period)
    #caso di prova28.3: period contiene un valore intero maggiore di dieci
    #obiettivo: period contiene un valore non valido e quindi @e deve essere non valido
    @e.period=11
    assert !@e.valid?
    assert @e.errors.invalid?(:period)
    #caso di prova28.4: period contiene un valore intero compreso tra uno e dieci
    #obiettivo: period contiene un valore valido e quindi in quell'attributo il sistema
    #non deve segnalare nessun errore
    @e.period=4
    assert !@e.valid?
    assert !@e.errors.invalid?(:period)
  end
end
