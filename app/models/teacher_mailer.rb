class TeacherMailer < ActionMailer::Base
  

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
