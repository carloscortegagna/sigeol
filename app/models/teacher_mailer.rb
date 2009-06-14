#=QuiXoft - Progetto SIGEOL
#NOME FILE:: teacher_mailer.rb
#AUTORE:: Beggiato Andrea
#DATA CREAZIONE:: 27/02/2009
#REGISTRO DELLE MODIFICHE::
# 14/03/2009 Approvazione del responsabile
#
# 27/02/2009 Prima stesura
#
# Rappresenta lo strumento con il quale vengono inviate le notifiche ai docenti

class TeacherMailer < ActionMailer::Base

include ApplicationHelper
  #Crea la mail contenente le istruzioni per l'attivazione di uno _User_ per un docente del sistema SIGEOL.
  def activate_teacher(sender, receiver)
    url = url_for(:only_path => false, :controller => "teachers", :action => "pre_activate", :id => receiver.id, :digest => receiver.digest)
    subject    'Creazione account SIGEOL'
    recipients receiver.mail
    from       sender.mail
    sent_on    Time.now
    content_type "text/html"
    body       :url => url, :teacher => receiver, :current_user => sender
  end

  def constraint_in_preference(sender, receiver,constraint)
    subject    'SIGEOL: Vincolo convertito in preferenza'
    recipients receiver.mail
    from       sender.mail
    sent_on    Time.now
    content_type "text/html"
    body  :teacher => receiver, :current_user => sender, :constraint=> constraint, :day=>from_id_to_dayname(constraint.day)
  end

  def suggestion_timetables(receiver, graduate_course, teaching_in_error)
    puts "MANDIAMO"
    sender = nil
    graduate_course.users.each do |u|
      if u.specified_type == "DidacticOffice"
        sender = u
        break
      end
    end
    soggetto = "SIGEOL: Orario non generato per il corso di laurea " + graduate_course.name + ". Suggerimento di modifica"
    subject    soggetto
    recipients receiver.mail
    from       sender.mail
    sent_on    Time.now
    content_type "text/html"
    body :teacher => teaching_in_error.teacher, :graduate_course => graduate_course
  end
end
