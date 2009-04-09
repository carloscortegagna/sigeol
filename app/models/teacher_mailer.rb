#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: teacher_mailer.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 27/02/09
#REGISTRO DELLE MODIFICHE:
#27/02/09 Prima stesura

class TeacherMailer < ActionMailer::Base

  def activate_teacher(sender, receiver)
    url = url_for(:only_path => false, :controller => "teachers", :action => "pre_activate", :id => receiver.id, :digest => receiver.digest)
    subject    'Creazione account SIGEOL'
    recipients receiver.mail
    from       sender.mail
    sent_on    Time.now
    content_type "text/html"
    body       :url => url
   puts url
  end

end
