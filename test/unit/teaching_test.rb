#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: teaching_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class TeachingTest < ActiveSupport::TestCase

  #test42: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
    # nel database
  test"Il contenuto degli attributi non deve essere nullo"do
    #caso di prova42.1:  t ha tutti gli attributi nulli
    #obiettivo: il sistema deve riconoscere t come oggetto non valido; in particolare deve
      #essere segnalato un errore in ogni attributo
    t=Teaching.new
    assert !t.valid?
    assert t.errors.invalid?(:name)
    assert t.errors.invalid?(:period_id)
  end

  #test43: cfu, labhours, classhours e studentsNumber devono essere interi
  test"cfu labhours classhours e studentsNumber devono essere interi"do
    #caso di prova43.1: i quattro attributi contengono un valore decimale
    #obiettivo: il sistema deve riconoscere t come non valido; in particolare dovrà riscontrare
      #un errore in tutti e quattro gli attributi sotto studio
    t=Teaching.new(:name=>"Analisi 2")
    t.CFU=20.5
    t.labHours=12.5
    t.classHours=12.5
    t.studentsNumber=12.5
    assert !t.valid?
    assert t.errors.invalid?(:CFU)
    assert t.errors.invalid?(:classHours)
    assert t.errors.invalid?(:labHours)
    assert t.errors.invalid?(:studentsNumber)
  end

  #test44: cfu, labhours e classhours e studentsNumber devono essere positivi
  test"cfu labhours e classhours e studentsNumber devono essere positivi"do
    #caso di prova44.1: i quattro attributi contengono valori negativi
    #obiettivo: lo stesso del caso di prova 43.1
    t=Teaching.new
    t.CFU=-20
    t.labHours=-12
    t.classHours=-12
    t.studentsNumber=-12
    assert !t.valid?
    assert t.errors.invalid?(:CFU)
    assert t.errors.invalid?(:classHours)
    assert t.errors.invalid?(:labHours)
    assert t.errors.invalid?(:studentsNumber)
    end

    #test45: cfu deve essere minore di 20,
    # labhours e classhours devono essere minore di 50
    #studentsNumber minore di 1000
  test"il valore di lab_hours classhours e cfu deve essere interno ad un deteminato intervallo"do
    #caso di prova45.1: i quattro attributi contengono valori superiori rispetto alle soglie
    #obiettivo: lo stesso del caso di prova 43.1
    t=Teaching.new
    t.CFU=21
    t.labHours=51
    t.classHours=51
    t.studentsNumber=1001
    assert !t.valid?
    assert t.errors.invalid?(:CFU)
    assert t.errors.invalid?(:classHours)
    assert t.errors.invalid?(:labHours)
    assert t.errors.invalid?(:studentsNumber)
  end

  #test46: il periodo di un insegnamento deve essere compatibile con la durata e l'organizzazione
  #accademica del corso di laurea a cui appartiene il curriculum associato
  test"Il periodo di un insegnamento deve essere valido"do
    #caso di prova46.1: teaching_3 non è compatibile con curriculum_1
    #obiettivo: il sistema deve riconoscere l'incompatibilità e aggiungere un errore all'attributo period
    #di teachings_3
    t=teachings(:teaching_3)
    c=curriculums(:curriculum_1)
    t.belongs.build(:curriculum => c, :isOptional => true)
    assert !t.save
    assert t.errors.invalid?(:period)
  end
end