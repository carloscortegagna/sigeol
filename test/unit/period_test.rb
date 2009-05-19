#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: period_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class PeriodTest < ActiveSupport::TestCase

  #test32: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
    # nel database
 test"Il contenuto degli attributi non deve essere nullo"do
    #caso di prova32.1: p ha tutti gli attributi nulli
    #obiettivo: il sistema deve riconoscere p come oggetto non valido; in particolare deve
      #essere segnalato un errore in ogni attributo
    p=Period.new
    assert !p.valid?
    assert p.errors.invalid?(:subperiod)
    assert p.errors.invalid?(:year)
  end

 #test33: year deve contenere un intero compreso tra uno e sei
  test"year per essere valido deve rispettare un insieme di regole"do
   p=Period.new
   #caso di prova33.1: year contiene un valore negativo
   #obiettivo: year contiene un valore non valido e quindi p deve essere non valido
    p.year=-1
    assert !p.valid?
    assert p.errors.invalid?(:year)
    #caso di prova33.2: year contiene un valore decimale
    #obiettivo: year contiene un valore non valido e quindi p deve essere non valido
    p.year=1.2
    assert !p.valid?
    assert p.errors.invalid?(:year)
   #caso di prova33.3: year contiene un valore maggiore di sei
   #obiettivo: year contiene un valore non valido e quindi p deve essere non valido
    p.year=7
    assert !p.valid?
    assert p.errors.invalid?(:year)
    #caso di prova33.4: year contiene un valore valido
    #obiettivo: duration contiene un valore valido e quindi in quell'attributo il sistema
     #non deve segnalare nessun errore
     p.year=6
     assert !p.valid?
    assert !p.errors.invalid?(:year)
  end

#test34: subperiod deve contenere un intero compreso tra uno e quattro
 test"subperiod per essere valido deve rispettare un insieme di regole"do
    p=Period.new
    #caso di prova34.1: subperiod contiene un valore negativo
    #obiettivo: subperiod contiene un valore non valido e quindi p deve essere non valido
    p.subperiod=-1
    assert !p.valid?
    assert p.errors.invalid?(:subperiod)
    #caso di prova34.2: subperiod contiene un valore decimale
    #obiettivo: subperiod contiene un valore non valido e quindi p deve essere non valido
    p.subperiod=1.2
    assert !p.valid?
    assert p.errors.invalid?(:subperiod)
    #caso di prova34.3: subperiod contiene un valore maggiore di cinque
    #obiettivo: subperiod contiene un valore non valido e quindi p deve essere non valido
    p.subperiod=5
    assert !p.valid?
    assert p.errors.invalid?(:subperiod)
    #caso di prova34.4: subperiod contiene un valore valido
    #obiettivo: subperiod contiene un valore valido e quindi in quell'attributo il sistema
      #non deve segnalare nessun errore
    p.subperiod=4
    assert !p.valid?
    assert !p.errors.invalid?(:subperiod)
  end

#test35: non devono essere presenti periodi con gli stessi valori contenuti negli attributi
 test"Non devono essere presenti periodi con gli stessi valori di year e subperiod"do
  #caso di prova35.1: p è un oggetto Period con lo stesso year e subperiod di period_1
  #obiettivo: il sistema deve riconoscere p come non valido in quanto i valori dei suoi attributi
    #sono già presenti in un'altra tupla
  p=Period.new(:year=>periods(:period_1).year,:subperiod=>periods(:period_1).subperiod)
  assert !p.save
  assert_equal "Sotto periodo e anno già presenti", p.errors.on(:base)
end

end
