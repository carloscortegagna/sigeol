#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: timetable_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class TimetableTest < ActiveSupport::TestCase

  #test55: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
     # nel database
  def test_attribute_not_nil
    #caso di prova55.1: t ha tutti gli attributi nulli
   #obiettivo: il sistema deve riconoscere t come oggetto non valido; in particolare deve
      #essere segnalato un errore in ogni attributo
    t=Timetable.new
    assert !t.valid?
    assert t.errors.invalid?(:year)
    assert t.errors.invalid?(:isPublic)
    assert t.errors.invalid?(:period_id)
    assert t.errors.invalid?(:graduate_course_id)
    
  end

  #test56: year deve essere una stringa del tipo 2008-09, dove i primi quattro caratteri devono
    #corrispondere o all'anno di sistema o al precedente e gli ultimi due devono rappresentare
    #un intero incrementato di uno rispetto alle cifra composta dal secondo e terzo carattere
  def test_validate_year
    #caso di prova56.1: year assume un valore totalmente casuale
    #obiettivo: t non deve essere valido perchè l'attributo year possiede un errore
    t=Timetable.new
    t.year="20000-20"
    assert !t.valid?
    assert t.errors.invalid?(:year)
    #caso di prova56.2: year assume nei primi quattro caratteri un valore precedente all'anno di sistema-1
    #obiettivo: identico al caso di prova 56.1
    t.year="2007-08"
    assert !t.valid?
    assert t.errors.invalid?(:year)
    #caso di prova56.3: year ha gli ultimi due caratteri non validi
    #obiettivo: identico al caso di prova 56.1
    t.year="2008-10"
    assert !t.valid?
    assert t.errors.invalid?(:year)
    #caso di prova56.4: year è valido
    #obiettivo: il sistema non deve rilevare errori nell'attributo year
    t.year="2008-09"
    assert !t.valid?
    assert !t.errors.invalid?(:year)
  end

  #test57: non possono esistere due timetable con gli stessi valori
  def test_unique
    #caso di prova57.1: t assume gli stessi valori di timetable_1
   #obiettivo: il sistema deve ricoscere t come un oggetto non valido
    t=Timetable.new
    t.year=timetables(:timetable_1).year
    t.graduate_course=timetables(:timetable_1).graduate_course
    t.period=timetables(:timetable_1).period
    assert !t.valid?
    assert_equal "riga già presente", t.errors.on(:base)
  end

end
