#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: capability_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class CapabilityTest < ActiveSupport::TestCase
  
#test16: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
# nel database
def test_attribute_not_nil
    #caso di prova16.1: c contiene un oggetto con attributi nulli.
    #obiettivo: Il sistema deve riconoscere c come un oggetto non valido.
    c=Capability.new
    assert !c.valid?
    assert c.errors.invalid?(:name)
   end

#test17: una capability non può avere lo stesso nome di un'altra
def test_unique_name
  #caso di prova17.1: creazione di una capability con lo stesso nome di un'altra
  #obiettivo: il sistema deve riconoscere c come un oggetto non valido
    c=Capability.new
    c.name=capabilities(:capability_1).name
    assert !c.save
    assert_equal  "La capability è già presente", c.errors.on(:name)
  end

end