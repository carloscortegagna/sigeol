#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: boolean_constraint_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class BooleanConstraintTest < ActiveSupport::TestCase

  #test10: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
  # nel database
  def test_attribute_not_nil
    #caso di prova10.1: b contiene un oggetto con tutti gli attributi nulli
    #obiettivo: il sistema deve riconoscere b come un oggetto non valido; in particolare deve riscontrare il problema
    #su tutti gli attributi di b
    b=BooleanConstraint.new
    assert !b.valid?
    assert b.errors.invalid?(:bool)
    assert b.errors.invalid?(:isHard)
    assert b.errors.invalid?(:description)
  end

  #test11: studio del comportamento della variabile booleana bool
  def test_bool_must_be_valid
    #caso di prova11.1: bool assume il valore 3
    #obiettivo: il valore 3 deve essere convertito a false
    b=BooleanConstraint.new
    b.bool=3
    assert_equal b.bool, false
    #caso di prova11.2: bool assume il valore 1
    #obiettivo: il valore 1 deve essere convertito a true
    b.bool=1
    assert_equal b.bool, true
    #caso di prova11.3: bool assume il valore 0
    #obiettivo: il valore 0 deve essere convertito a false
    b.bool=0
    assert_equal b.bool, false
  end

  #test12: isHard deve contenere solo valori interi compresi tra 0 e 10
  def test_isHard_must_be_valid
    #caso di prova12.1: isHard contiene il valore 11
    #obiettivo: il sistema deve riconoscere che b non è valido; in particolare deve riscontrare
    #l'errore sull'attributo isHard
    b=BooleanConstraint.new
    b.isHard=11
    assert !b.valid?
    assert b.errors.invalid?(:isHard)
    #caso di prova12.2: isHard contiene il valore -1
    #obiettivo: lo stesso del caso di prova 12.1
    b.isHard=-1
    assert !b.valid?
    assert b.errors.invalid?(:isHard)
    #caso di prova12.2: isHard contiene il valore 1.1
    #obiettivo: lo stesso del caso di prova 12.1
    b.isHard=1.1
    assert !b.valid?
    assert b.errors.invalid?(:isHard)
    #caso di prova12.2: isHard contiene il valore 0
    #obiettivo: il contenuto di isHard deve essere riconosciuto come valido
    b.isHard=0
    assert !b.valid?
    assert !b.errors.invalid?(:isHard)
    end
end
