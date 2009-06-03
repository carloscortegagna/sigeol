#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: curriculum_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class CurriculumTest < ActiveSupport::TestCase

  #test21: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
    # nel database
  test"Il contenuto di name non deve essere nullo"do
    #caso di prova21.1: c è un oggetto di tipo Curriculum con tutti gli attributi nulli
    #obiettivo: il sistema deve riconoscere c come oggetto non valido
    c=Curriculum.new
    assert !c.valid?
    assert c.errors.invalid?(:name)
  end

  #test22: un curriculum non può avere lo stesso nome di un altro associato allo stesso corso di laurea
  test"Curricula associati allo stesso corso di laurea non possono avere lo stesso nome"do
    #caso di prova22.1: c è un oggetto che contiene lo stesso nome e corso di laurea di una tupla
      #già presente nel db
    #obiettivo: poichè esiste già una tupla con lo stesso nome e corso di laurea, il sistema deve riconoscere
      #come non valido l'oggetto c
    c=Curriculum.new
    c.graduate_course=curriculums(:curriculum_1).graduate_course
    c.name=curriculums(:curriculum_1).name
    assert !c.valid?
    assert_equal "E' gia presente un curriculum con questo nome", c.errors.on(:name)
  end

  #test23: eliminazione  di un insegnamento associato
    #teaching_1 è un insegnamento( con name=Ingegneria del software) associato a due curriculum:
    #curriculum_1 e curriculum_2
  test"Cancellazione di un insegnamento associato a due curricula"do
    #caso di prova 23.1: curriculum_1 non è più associato a teaching_1
    #obiettivo: dopo l'operazione c.teachings.delete(t), teaching_1 deve essere ancora presente nel db
    c=curriculums(:curriculum_1)
    t=teachings(:teaching_1)
    c.teachings.delete(t)
   assert Teaching.find_by_name("Ingegneria del software")
   #caso di prova 23.2: eliminazione  di un insegnamento associato
   #obiettivo: dopo l'operazione c.teachings.delete(t), teaching_1 non è associato a nessun curriculum
    #e quindi deve essere cancellato
   c=curriculums(:curriculum_2)
   c.teachings.delete(t)
   assert !Teaching.find_by_name("Ingegneria del software")
  end

  #test24: eliminazione di un curriculum.
    #curriculum_1 e curriculum_2 sono associati ad uno stesso insegnamento nominato Ingegneria del software
  test"cancellazione di un curriculum"do
    #caso di prova24.1: eliminazione di curriculum_1
    #obiettivo: dopo aver eliminato curriculum_1 l'insegnamento con nome uguale a Ingegneria del software
      #deve essere ancora presente
    assert curriculums(:curriculum_1).destroy
    assert Teaching.find_by_name("Ingegneria del software")
    #caso di prova24.2: eliminazione di curriculum_2
    #obiettivo: dopo aver eliminato curriculum_2, l'insegnamento non essendo associato a nessun'altro
      #curriculum dev'essere cancellato
    assert curriculums(:curriculum_2).destroy
    assert !Teaching.find_by_name("Ingegneria del software")
  end
end
