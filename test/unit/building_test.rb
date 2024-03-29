#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: building_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class BuildingTest < ActiveSupport::TestCase
 def setup
   @b=Building.new
 end

 #test13: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
  # nel database
 test"Il contenuto degli attributi non deve essere nullo"do
   #caso di prova13.1: @b  contiene un oggetto con attributi nulli.
   #obiettivo: il sistema deve riconoscere @b come non valido; in particolare deve riscontrare
     #l'errore nell'unico attributo che possiede(name)
   assert !@b.valid?
   assert @b.errors.invalid?(:name)
 end
 
 #test14: non devono esistere due palazzi con lo stesso nome
 test"Non devono esistere due palazzi con lo stesso nome"do
   #caso di prova 14.1: assegno a @b un nome che è già stato assegnato ad un altro palazzo
   #obiettivo: il sistema deve riconoscere @b come non valido perchè ha lo stesso nome
    #un altro palazzo già presente come tupla
   @b.name= buildings(:building_1).name
   assert !@b.valid?
   assert_equal "Esiste già un palazzo con questo nome", @b.errors.on(:name)
 end

 #test15: eliminazione di un palazzo
 test"Eliminazione di un palazzo"do
   #caso di prova 15.1: si elimina la tupla buildings_1
   #obiettivo: eliminandola non deve più esistere l'indirizzo associato e tutte le classi appartenenti.
    #buildings_1 è associato ad un indirizzo(address_2) e ad una classe(classroom_1)
    @b=buildings(:building_1)
    assert @b.destroy
    assert_raise(ActiveRecord::RecordNotFound){Address.find(@b.address_id)}
    assert !Classroom.find_by_building_id(@b.id)
 end

end
