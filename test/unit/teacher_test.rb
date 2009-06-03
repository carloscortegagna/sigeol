#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: teacher_test.rb
#AUTORE: Grosselle Alessandro
require 'test_helper'

class TeacherTest < ActiveSupport::TestCase

  #test40: un oggetto se dopo un aggiornamento presenta attributi nulli, non deve essere valido.
  test"Un oggetto se dopo un aggiornamento presenta attributi nulli non deve essere valido "do
    #caso di prova40.1: t viene aggiornato mettendo tutti gli attributi a nil
    # obiettivo: il sistema deve riconoscere t come oggetto non valido; in particolare deve
      #essere segnalato un errore in ogni attributo
    t=teachers(:teacher_1)
    t.complete_name
    t.name=""
    t.surname=""
    assert !t.valid?
    assert t.errors.invalid?(:name)
    assert t.errors.invalid?(:surname)
  end

  #test41:  eliminazione di un teacher
  test"eliminazione di un teacher"do
    #caso di prova41.1: cancellazione di teacher_1.
    #obiettivo: oltre a teacher_1 devono essere eliminati anche i vincoli(Constraints)
      #e lo User associato. teacher_1 ha un unico vincolo temporale
    t=teachers(:teacher_1)
    c=TemporalConstraint.new(:day=>1,:startHour=>Time.parse("9:30"),:endHour=>Time.parse("12:30"),:isHard=>0)
    c.description="I quei giorni, insegno in un altro dipartimento"
    c.save
    t.constraints<<c
    t.save
    u=users(:user_2)
    u.specified=t
    u.save
    t.destroy
    #prima della cancellazione di teacher_1, TemporalConstraint conteneva due tuple
    assert_equal TemporalConstraint.count, 1
    assert_raise(ActiveRecord::RecordNotFound){User.find(u.id)}
  end
end