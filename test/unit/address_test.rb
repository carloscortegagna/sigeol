#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: address_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  def setup
    @a=Address.new
  end

 #test5: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
  # nel database
  def test_attribute_not_nil
    #caso di prova5.1: @a contiene un oggetto con tutti gli attributi nulli.
    #obiettivo: il sistema deve riconoscere @a come un oggetto non valido.
   assert !@a.valid?
   assert_equal "Inserisci la città" , @a.errors.on(:city).first
   assert_equal "Inserisci la via" , @a.errors.on(:street).first
  end

  #test6: l'attributo telephone deve rispettare l'espressione regolare /^[0-9]{2,4}\-[0-9]{6,8}$/
  def test_correct_telephone
    #caso di prova6.1: il prefisso ha più di quattro cifre
    #obiettivo: @a non deve essere valido a causa del contenuto non corretto di telephone
    @a.telephone="12345-123456"
    assert !@a.valid?
    assert_equal "Inserisci in questo modo: prefisso-numero" , @a.errors.on(:telephone)
    #caso di prova6.2: il prefisso è corretto ma il numero contiene meno di sei cifre
    #obiettivo: lo stesso del caso d'uso 6.1
    @a.telephone="1234-12345"
    assert !@a.valid?
    assert_equal "Inserisci in questo modo: prefisso-numero" , @a.errors.on(:telephone)
    #caso di prova 6.3: il numero di telefono contiene caratteri alfabetici
    #obiettivo: lo stesso del caso d'uso 6.1
    @a.telephone="1a23-12345"
    assert !@a.valid?
    assert_equal "Inserisci in questo modo: prefisso-numero" , @a.errors.on(:telephone)
    assert !@a.valid?
    #caso di prova 6.4: il numero di telefono rispetta l'espressione regolare
   #obiettivo: il sistema deve riconoscere @a come un oggetto valido
  @a.telephone="1234-123456"
  assert !@a.valid?
end

  #test7: eliminazione di un indirizzo associato ad uno user
    def test_destroy_address_in_user_address_id_must_nil
      #caso di prova 7.1: eliminazione di una tupla della tabella address
      #obiettivo: eliminata la tupla, lo user associato deve avere il contenuto della chiave esterna(address_id) a nil
      addresses(:address_1).delete
      !assert(users(:user_1).address_id)
    end

  #test8: eliminazione di un indirizzo associato ad uno building
    def test_destroy_address_in_building_address_id_must_nil
      #caso di prova8.1:eliminazione di una tupla della tabella address
      #obiettivo: eliminata la tupla, il building associato deve avere il contenuto della chiave esterna(address_id) a nil
      addresses(:address_2).delete
      !assert(buildings(:building_1).address_id)
    end

   #test9: inserimento di un indirizzo completamente corretto
    def test_correct_address
     #caso di prova9.1: inserimento di un indirizzo completamente corretto
     #obiettivo: tutti gli attributi devono essere validi e quindi l'oggetto @a può essere salvato nel db.
    @a.telephone="049-9050231"
    @a.street="Via Belzoni 6"
    @a.city="Villafranca veronese"
    assert @a.save
  end

  end
