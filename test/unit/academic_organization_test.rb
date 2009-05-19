#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: academic_organization_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class AcademicOrganizationTest < ActiveSupport::TestCase
  def setup
    @a=AcademicOrganization.new
  end

#test1: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
# nel database
  test"Il contenuto degli attributi non deve essere nullo" do
    #caso di prova1.1: @a contiene un oggetto con attributi nulli.
    #obiettivo: Il sistema deve riconoscere @a come un oggetto non valido.
    assert !@a.valid?
    assert @a.errors.invalid?(:name)
    assert @a.errors.invalid?(:number)
  end

  #test2: number deve contenere un valore intero compreso tra 1 e 6
  test"number deve accettare determinati valori" do
    #caso di prova2.1: number contiene il valore 0.
    #obiettivo: Il sistema deve riconoscere @a come un oggetto non valido; in particolare deve riscontrare l'errore nel contenuto di number.
    @a.number=0
    assert !@a.valid?
    assert_equal "Il numero deve essere compreso tra 1 e 4" , @a.errors.on(:number)
    #caso di prova2.2= number contiene il valore 7.
    #obiettivo: lo stesso del caso di prova 2.1
    @a.number=7
    assert !@a.valid?
    assert_equal "Il numero deve essere compreso tra 1 e 4" , @a.errors.on(:number)
    #caso di prova 2.3:number contiene il valore 3
    #obiettivo: number contiene un valore corretto e quindi @a deve essere un oggetto valido
    @a.name="Trimestre"
    @a.number=3
    assert @a.valid?
  end

#test3: l'attributo name deve contenere solo caratteri
 test"Il contenuto di nome per essere valido deve rispettare un insieme di regole " do
   #caso di prova 3.1: name contiene valori numerici
   #obiettivo: il sistema deve riconoscere @a come non valido; in particolare deve riscontrare
    #un errore nel attributo name
   @a.name="12a34"
   assert !@a.valid?
   assert_equal "Si accetta solo caratteri" , @a.errors.on(:name)
   #caso di prova 3.2: name contiene un valore valido
   #obiettivo: il sistema deve riconoscere @a come valido.
   @a.name="Trimestre"
   @a.number=3
   assert @a.valid?
  end

  #test4: non devono esserci organizzazioni accademiche con ugual contenuto di
    #name o di number
  test"Non devono esistere piu tuple con la stessa coppia di valori contenuti in name e number" do
    #caso di prova4.1: a name e number vengono assegnati gli stessi valori di una tupla già presente nel db
    #obiettivo: il sistema deve riconoscere @a come oggetto non valido; in particolare deve riscontrare che
     #nel db son già presenti tuple con quei valori
    @a.name=academic_organizations(:academic_organization_1).name
    @a.number=academic_organizations(:academic_organization_1).number
    assert !@a.valid?
    assert_equal "E' gia presente un organizzazione accademica con questo nome" , @a.errors.on(:name)
    assert_equal "E' gia presente un organizzazione accademica con questo numero" , @a.errors.on(:number)
  end

end

