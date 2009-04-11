#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: quantity_constraint_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class QuantityConstraintTest < ActiveSupport::TestCase
 
 #test36: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
    # nel database
  def test_attribute_not_nil
    #caso di prova36.1: q ha tutti gli attributi nulli
    #obiettivo: il sistema deve riconoscere q come oggetto non valido; in particolare deve
      #essere segnalato un errore in ogni attributo
    q=QuantityConstraint.new
    assert !q.valid?
    assert q.errors.invalid?(:quantity)
    assert q.errors.invalid?(:isHard)
    assert q.errors.invalid?(:description)
  end

  #test37: isHard deve contenere un intero compreso tra zero e dieci
  def test_isHard_must_be_valid
    q=QuantityConstraint.new
    #caso di prova 37.1: isHard contiene un valore maggiore di dieci
    #obiettivo: isHard contiene un valore non valido e quindi q deve essere non valido
    q.isHard=11
    assert !q.valid?
    assert q.errors.invalid?(:isHard)
    #caso di prova 37.2: isHard contiene un valore negativo
    #obiettivo: isHard contiene un valore non valido e quindi q deve essere non valido
    q.isHard=-1
    assert !q.valid?
    assert q.errors.invalid?(:isHard)
    #caso di prova 37.3: isHard contiene un valore decimale
    #obiettivo: isHard contiene un valore non valido e quindi q deve essere non valido
    q.isHard=1.1
    assert !q.valid?
    assert q.errors.invalid?(:isHard)
    #caso di prova 37.4: isHard contiene un valore compreso tra zero e dieci
    #obiettivo: isHard contiene un valore valido e quindi in quell'attributo il sistema
      #non deve segnalare nessun errore
    q.isHard=0
    assert !q.valid?
    assert !q.errors.invalid?(:isHard)
    end

  #test38: quantity deve contenere un intero compreso tra uno e mille
  def test_quantity_must_be_valid
    #caso di prova 38.1: quantity contiene un valore maggiore di mille
    #obiettivo: quantity contiene un valore non valido e quindi q deve essere non valido
    q=QuantityConstraint.new
    q.quantity=1001
    assert !q.valid?
    assert q.errors.invalid?(:quantity)
    #caso di prova 38.2: quantity contiene un valore negativo
    #obiettivo: quantity contiene un valore non valido e quindi q deve essere non valido
    q.quantity=-1
    assert !q.valid?
    assert q.errors.invalid?(:quantity)
    #caso di prova 38.3: quantity contiene un valore decimale
    #obiettivo: quantity contiene un valore non valido e quindi q deve essere non valido
    q.quantity=1.1
    assert !q.valid?
    assert q.errors.invalid?(:quantity)
    #caso di prova 38.4: quantity contiene un valore compreso tra uno e mille
    #obiettivo: quantity contiene un valore valido e quindi in quell'attributo il sistema
      #non deve segnalare nessun errore
    q.quantity=1
    assert !q.valid?
    assert !q.errors.invalid?(:quantity)
  end
end
