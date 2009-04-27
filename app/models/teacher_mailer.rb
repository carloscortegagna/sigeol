#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: teacher_mailer.rb
#VERSIONE:: 1.0.0
#AUTORE:: Beggiato Andrea
#DATA CREAZIONE:: 27/02/09
#REGISTRO DELLE MODIFICHE::
# 14/03/09 Approvazione del responsabile
#
# 27/02/09 Prima stesura
#
# Rappresenta lo strumento con il quale vengono inviate le notifiche ai docenti

class TeacherMailer < ActionMailer::Base

  #Crea la mail contenente le istruzioni per l'attivazione di uno _User_ per un docente del sistema SIGEOL.
  def activate_teacher(sender, receiver)
    url = url_for(:only_path => false, :controller => "teachers", :action => "pre_activate", :id => receiver.id, :digest => receiver.digest)
    subject    'Creazione account SIGEOL'
    recipients receiver.mail
    from       sender.mail
    sent_on    Time.now
    content_type "text/html"
    body       :url => url
  end
end
