#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: timetable_entry_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class TimeTableEntryTest < ActiveSupport::TestCase
  
  #test51: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
     # nel database
  def test_attribute_not_nil
   #caso di prova51.1: t ha tutti gli attributi nulli
   #obiettivo: il sistema deve riconoscere t come oggetto non valido; in particolare deve
      #essere segnalato un errore in ogni attributo
   t=TimetableEntry.new
   assert !t.valid?
   assert t.errors.invalid?(:startTime)
   assert t.errors.invalid?(:endTime)
   assert t.errors.invalid?(:timetable_id)
   assert t.errors.invalid?(:classroom_id)
  end

 #test52: day deve assumere un valore intero compreso tra uno e cinque
  def test_day_must_be_valid
    #caso di prova 52.1: day contiene un valore maggiore di cinque
    #obiettivo: day contiene un valore non valido e quindi t deve essere non valido
    t=TimetableEntry.new
    t.day=6
    assert !t.valid?
    assert t.errors.invalid?(:day)
   #caso di prova 52.2: day contiene un valore minore di uno
    #obiettivo: identico a quello del caso di prova 52.1
    t.day=0
    assert !t.valid?
    assert t.errors.invalid?(:day)
    #caso di prova 52.3: day contiene un valore decimale
    #obiettivo: identico a quello del caso di prova 52.1
    t.day=1.5
    assert !t.valid?
    assert t.errors.invalid?(:day)
    #caso di prova52.4: day contiene un valore valido
    #obiettivo: day contiene un valore valido e quindi in quell'attributo il sistema
      #non deve segnalare nessun errore
    t.day=1
    assert !t.valid?
    assert !t.errors.invalid?(:day)
  end

 #test53: il valore di startTime deve essere minore di quello contenuto in endTime
 def test_correct_time
  #caso di prova53.1: startTime assume un valore più grande di endTime
  #obiettivo: t non deve essere valido
  t=TimetableEntry.new
  t.startTime=Time.parse("9:30")
  t.endTime=Time.parse("6:30")
  assert !t.valid?
  assert t.errors.invalid?([:starTime,:endTime])
 end

#test54: non possono esistere due timetable_entry con gli stessi valori
 def test_unique
   #caso di prova54.1: t2 assume gli stessi valori di t
   #obiettivo: il sistema deve ricoscere t2 come un oggetto non valido
   t=create_timetable_entry
   assert t.save
   t2=create_timetable_entry
   assert !t2.save
   assert t2.errors.invalid?(:base)
   
 end 

 def create_timetable_entry
   t= TimetableEntry.new
   t.day=2
   t.startTime= Time.parse("9:30")
   t.endTime= Time.parse("11:30")
   t.timetable= timetables(:timetable_1)
   t.classroom= classrooms(:classroom_1)
   t.teaching= teachings(:teaching_1)
   return t
 end
end
