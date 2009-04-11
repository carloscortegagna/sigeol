#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: classroom_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class ClassroomTest < ActiveSupport::TestCase
  
  #test18: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
    # nel database
 def test_attribute_not_nil
    #caso di prova18.1: c contiene un oggetto con attributi nulli.
    #obiettivo: Il sistema deve riconoscere c come un oggetto non valido.
    c=Classroom.new
    assert !c.valid?
    assert c.errors.invalid?(:name)
    assert c.errors.invalid?(:building_id)
  end

 #test19: una classe associata ad un palazzo non può avere lo stesso nome di un'altra
  #appartenente allo stesso palazzo
 def test_unique_name_on_same_building
    #caso di prova19.1: c è un oggetto di tipo Classroom che ha lo stesso nome di un'altra classe
    #obiettivo: il sistema deve riconoscere c come un oggetto non valido in quanto possiede un
     #problema nell'attributo name
    c=Classroom.new
    c.name=classrooms(:classroom_1).name
    c.building=classrooms(:classroom_1).building
    assert !c.valid?
    assert_equal "Nel palazzo è gia presente un'aula con questo nome", c.errors.on(:base)
  end

 #test20: eliminazione di una classe
 def test_destroy
    #caso di prova20.1: eliminazione della tupla classroom_1
    #obiettivo: eliminandola non devono più esistere i constraints associati.
     #b è un vincolo booleano associato a c e rappresenta l'unica tupla presente nella tabella
     # BooleanConstaint.
    c=classrooms(:classroom_1)
    b=BooleanConstraint.new(:bool=>false,:isHard=>2,:description=>"descrizione")
    assert b.save
    c.constraints<<b
    assert c.save
    assert c.destroy
    assert_equal BooleanConstraint.count, 0
  end
end
