#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: graduate_course_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class GraduateCourseTest < ActiveSupport::TestCase
 
  #test29: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
    # nel database
  def test_attribute_not_nil
    #caso di prova29.1: g ha tutti gli attributi nulli
    #obiettivo: il sistema deve riconoscere g come oggetto non valido; in particolare deve
      #essere segnalato un errore in ogni attributo
    g=GraduateCourse.new
   assert !g.valid?
   assert g.errors.invalid?(:name)
   assert g.errors.invalid?(:duration)
   assert g.errors.invalid?(:academic_organization_id)
 end

  #test30: duration deve contenere un intero compreso tra uno e sei
   def test_valid_duration
    #caso di prova 30.1: duration contiene un valore negativo
    #obiettivo: duration contiene un valore non valido e quindi @e deve essere non valido
    g=GraduateCourse.new
    g.duration=-1
    assert !g.valid?
    assert g.errors.invalid?(:duration)
    #caso di prova 30.2: duration contiene un valore decimale
    #obiettivo: duration contiene un valore non valido e quindi @e deve essere non valido
     g.duration=1.1
    assert !g.valid?
    assert g.errors.invalid?(:duration)
    #caso di prova 30.3: duration contiene un valore maggiore di sei
    #obiettivo: duration contiene un valore non valido e quindi @e deve essere non valido
     g.duration=7
     assert !g.valid?
     assert g.errors.invalid?(:duration)
     #caso di prova30.4: duration contiene un valore intero compreso tra uno e sei
     #obiettivo: duration contiene un valore valido e quindi in quell'attributo il sistema
       #non deve segnalare nessun errore
     g.duration=6
     assert !g.valid?
     assert !g.errors.invalid?(:duration)
   end

  #test31: eliminazione di un corso di laurea
   def test_destroy_graduate_course
    #caso di prova 31.1: eliminazione di graduate_course_1. Quest'ultimo è associato
      #ad un academic_organizations, a due curriculums, ad un ExpiryDate e ad un BooleanConstraint.
    #A sua volta i due curriculum sono associati a due identici teaching.
      #obiettivo: dopo aver eliminato graduate_course_1, non devono essere presenti nel db gli
      #elementi associati.
      # Inoltre devono essere stati cancellati anche i due teaching associati ai due curriculums
    g=graduate_courses(:graduate_course_1)
     b=BooleanConstraint.new(:bool=>"true",:isHard=>0,:description=>"descrizione")
     assert b.save
     g.constraints<<b
     assert g.save
     assert g.destroy
     assert !ExpiryDate.find_by_graduate_course_id(g.id)
     assert !Curriculum.find_by_graduate_course_id(g.id)
     #Il numero di tuple in teachings prima della cancellazione di graduate_course_1 erano tre
     assert_equal Teaching.count, 1
     assert !Timetable.find_by_graduate_course_id(g.id)
     #In boolean_constraints prima della cancellazione di graduate_course_1 c'era una tupla
     assert_equal BooleanConstraint.count, 0
   end

end
