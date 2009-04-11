#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: temporal_constraint_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class TemporalConstraintTest < ActiveSupport::TestCase

  #test47: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
    # nel database
  def test_attribute_not_nil
    #caso di prova47.1: t ha tutti gli attributi nulli
    #obiettivo: il sistema deve riconoscere t come oggetto non valido; in particolare deve
      #essere segnalato un errore in ogni attributo
    t=TemporalConstraint.new
    assert !t.valid?
    assert t.errors.invalid?(:day)
    assert t.errors.invalid?(:startHour)
    assert t.errors.invalid?(:endHour)
    assert t.errors.invalid?(:description)
    assert t.errors.invalid?(:isHard)
  end

  #test48: day deve contenere un valore intero compreso tra uno e cinque
  def test_day_must_be_valid
    #caso di prova48.1: day contiene un valore maggiore di cinque
    #obiettivo: day contiene un valore non valido e quindi t deve essere non valido
    t=TemporalConstraint.new
    t.day=6
    assert !t.valid?
    assert t.errors.invalid?(:day)
    #caso di prova48.2: day contiene un valore minore di uno
    #obiettivo: lo stesso del caso di prova 48.1
    t.day=0
    assert !t.valid?
    assert t.errors.invalid?(:day)
    #caso di prova48.3: day contiene un valore decimale
    #obiettivo: lo stesso del caso di prova 48.1
    t.day=1.5
    assert !t.valid?
    assert t.errors.invalid?(:day)
    #caso di prova48.4: day contiene un valore valido
    #obiettivo: day contiene un valore valido e quindi in quell'attributo il sistema
      #non deve segnalare nessun errore
    t.day=1
    assert !t.valid?
    assert !t.errors.invalid?(:day)
  end
  
  #test49: isHard deve contenere un intero compreso tra zero e dieci
  def test_isHard_must_be_valid
    #caso di prova 49.1: isHard contiene un valore maggiore di dieci
    #obiettivo: isHard contiene un valore non valido e quindi t deve essere non valido
    t=TemporalConstraint.new
    t.isHard=11
    assert !t.valid?
    assert t.errors.invalid?(:isHard)
    #caso di prova 49.2: isHard contiene un valore negativo
    #obiettivo: identico a quello del caso di prova 49.1
    t.isHard=-1
    assert !t.valid?
    assert t.errors.invalid?(:isHard)
    #caso di prova 49.3: isHard contiene un valore negativo
    #obiettivo: identico a quello del caso di prova 49.1
    t.isHard=1.1
    assert !t.valid?
    assert t.errors.invalid?(:isHard)
   #caso di prova 49.4: isHard contiene un valore compreso tra zero e dieci
    #obiettivo: isHard contiene un valore valido e quindi in quell'attributo il sistema
      #non deve segnalare nessun errore
    t.isHard=0
    assert !t.valid?
    assert !t.errors.invalid?(:isHard)
    end

  #test50: il valore di startHour deve essere minore di quello contenuto in endHour
  def test_correct_time
    #caso di prova50.1: startHour assume un valore più grande di endHour
    #obiettivo: t non deve essere valido
    t=TemporalConstraint.new
    t.startHour=Time.parse("11:30")
    t.endHour=Time.parse("09:30")
    assert !t.valid?
    assert_equal "Attenzione l'ora di inizio è piu grande dell'ora di fine", t.errors.on([:starHour,:endHour])
  end

  end
