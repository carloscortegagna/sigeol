#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: quantity_constraint_test.rb
#AUTORE: Grosselle Alessandro

require 'test_helper'

class TeacherMailerTest < ActionMailer::TestCase
  def setup
    t=Teacher.new(:name=>"Alessandro",:surname=>"Grosselle")
    @receiver=users(:user_1)
    @receiver.specified=t
    @receiver.save
    d=DidacticOffice.new()
    d.save
    @sender=users(:user_2)
    @sender.specified=d
    @sender.save
  end

  #test39: attivazione dell'account tramite mail.
  #@sender e @ receiver  sono due oggetti di tipo User
  test"attivazione dell account tramite mail"do
    t=TeacherMailer.create_activate_teacher(@sender,@receiver)
    #caso di prova39.1: correttezza mail destinatario
    #obiettivo: l'indirizzo del destinatario della mail deve essere uguale al contenuto dell'attributo mail
    #di @receiver
    assert_equal(@receiver.mail, t.to.first)
    #caso di prova39.2: correttezza mail mittente 
    #obiettivo: l'indirizzo del mittente della mail deve essere uguale al contenuto dell'attributo mail
    #di @sender
    assert_equal(@sender.mail, t.from.first)
    #caso di prova39.3: correttezza del subject
    #obiettivo: il subject della mail deve essere uguale alla stringa Creazione account SIGEOL
    assert_equal("Creazione account SIGEOL", t.subject)
    #caso di prova39.4: correttezza dell'url necessario per l'attivazione dell'account
    #obiettivo: nel body della mail deve essere presente un url corretto. Per esserlo deve rispettare
    #l'espressione regolare riportata tra due /
    assert_match(/teachers\/#{@receiver.id}\/pre_activate\?digest=#{@receiver.digest}/, t.body)
  end
end
