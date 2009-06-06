#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: user_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'
require 'digest/sha1'

class UserTest < ActiveSupport::TestCase
  def setup
    d=DidacticOffice.new
    d.id=1
    d.save
    @u=users(:user_1)
    @u.capabilities<<Capability.find(:all)
    @u.specified=d
    @u.save
  end

  #test58: un oggetto con attributi nulli, non deve essere valido. Se non è valido non viene salvato
     # nel database
  test"Il contenuto degli attributi non deve essere nullo"do
    #caso di prova58.1: u ha tutti gli attributi nulli
    #obiettivo: il sistema deve riconoscere u come oggetto non valido; in particolare deve
      #essere segnalato un errore in ogni attributo
    u=User.new
    assert !u.errors.invalid?(:mail)
  end

  #test59: il contenuto di password deve avere più di sei caratteri di tipo alfanumerico
  test"password deve avere piu di sei caratteri di tipo alfanumerico"do
    #caso di prova59.1: la password è vuota
    #obiettivo: non essendo corretto il contenuto di password,
     # il sistema deve riconoscere @u come non valido
    @u.password=""
    assert !@u.save
    assert_equal "La password non deve essere vuota", @u.errors.on(:password).first

    #caso di prova59.2: la password contiene meno di cinque caratteri
    #obiettivo: lo stesso dele caso prova 59.2
    @u.password="prova"
    assert !@u.save
    assert_equal "Minimo 6 caratteri", @u.errors.on(:password)

    #caso di prova59.3: la password contiene un valore corretto
    #obiettivo: il sistema non deve riscontrare nessun errore in password
    @u.password="pro.va"
    assert @u.save
  end

 #test60: mail deve rispettare l'espressione regolare definita
  test"mail deve rispettare l espressione regolare definita"do
    #caso di prova60.1: mail contiene al suo interno un carattere non valido: ?
    #obiettivo: a causa del contenuto della mail non corretto,
      #il sistema deve riconoscere @u come un oggetto non valido
    @u.mail="prova?id=1@math.unipd.it"
    assert !@u.save
    assert_equal "La mail non è valida", @u.errors.on(:mail)
    #caso di prova60.2: il contenuto di mail rispetta l'espressione regolare
    #obiettivo: il sistema non deve riscontrare nessun errore nel contenuto di mail
    @u.mail="agrossel@math.unipd.it"
    assert @u.save
  end

  #test61: non possono esistere due tuple in users con lo stesso valore di mail
  test"Non possono esistere due tuple con lo stesso valore di mail"do
    #caso di prova61.1: u contiene la stessa mail di user_2
    #obiettivo: il sistema deve riconoscere u come non valido dato che possiede una mail già presente
      #in una tupla di users
    u=User.new(:mail=>users(:user_2).mail,:random=>2)
    assert !u.save
    assert_equal "La mail è già presente", u.errors.on(:mail)
  end

 #test62: la password deve essere salvata crittografata
  test"la password deve essere salvata crittografata"do
   #caso di prova62.1: la varibile locale password contiene il valore dell'attributo password di user_1
    # p è una variabile locale che contiene la password di user_1(alessandro) crittografata
   #obiettivo: password e p devono contenere lo stesso valore; ovvero la stringa "alessandro"
    #crittografata
   password=User.find(users(:user_1).id).password
   p=Digest::SHA1.hexdigest("alessandro")
   assert_equal password, p
 end

#test63: uno user deve essere specificato
  test"Uno user deve essere specificato"do
  d=DidacticOffice.new
  d.save
  #caso di prova63.1: u non è specificato
  #obiettivo: u non è specificato quindi non deve essere valido
  u=users(:user_2)
  assert !u.save
  #caso di prova63.2: u è specificato
  #obiettivo: il sistema deve riconoscere u come un oggetto valido
  u.specified=d
  assert u.save
end

#test64: test del metodo authenticate
  test"test del metodo authenticate"do
  #caso di prova64.1: ad authenticate vengono passati uno user ed una password non corretti
  #obiettivo: il metodo deve tornare un valore booleano pari a false
   u=User.authenticate("prova@math.unipd.it", "password")
  assert !u
  #caso di prova64.2: ad authenticate vengono passati uno user ed una password corretti
  #obiettivo: il metodo deve tornare l'oggetto di tipo User che possiede quei valori
  u=User.authenticate("agrossel@math.unipd.it", "alessandro")
  assert u.active?
end

 #test65: distuzione corretta di uno user
  test"distuzione corretta di uno user"do
  #caso di prova65.1: cancellazione della tupla riferita dall'oggetto @u
  #obiettivo: oltre alla tupla devono essere eliminati tutti gli elementi associati
  assert @u.destroy
  assert_raise(ActiveRecord::RecordNotFound) { DidacticOffice.find( @u.specified_id ) }
  assert_raise(ActiveRecord::RecordNotFound) { Address.find(@u.address_id) }
  end

 #test66: test dei metodi manage_
test"test dei metodi manage_"do
  #caso di prova66.1: @u contiene tutte i privilegi
  #obiettivo: tutti i metodi manage_ devono ritornare true
  c =Capability.find(:all)
   c.each do |v|
     puts v.name
   end
   assert @u.manage_buildings?
  assert @u.manage_capabilities?
  assert @u.manage_classrooms?
  assert @u.manage_graduate_courses?
  assert @u.manage_teachers?
  assert @u.manage_timetables?
  assert @u.manage_teachings?
end

#test67: test dei metodi own_by_
test"test dei metodi own_by_"do
  #caso di prova67.1: @u è associato ad una segreteria didattica(didactic_office)
  #obiettivo: chiamando su @u, own_by_didactic_office? deve tornare true mentre own_by_teacher? false
  assert @u.own_by_didactic_office?
  assert !@u.own_by_teacher?
end
#-------------------non serve!!---------------------------------------------------------------------------
#test68: cancellazione di uno user associato ad almeno un corso di laurea
#def test_try_to_destroy_user_associated_to_graduate_course
  #caso di prova68.1: @ u è associato al corso di laurea graduate_course_1
  #obiettivo: tentando di cancellare @u, si deve sollevare un'eccezione. Di conseguenza @u non deve
    #essere eliminato
  #@u.graduate_courses<<graduate_courses(:graduate_course_1)
  #@u.save
  #assert_raise(Exception){@u.destroy}
#end
end
