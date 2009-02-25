# Methods added to this helper will be available to all templates in the application.
#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: application_herlper.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#17/02/09 Raccolta delle espressioni regolari e delle costanti utili per le validazioni
#16/02/09 Aggiunta della funzione first_upper

#passata una stringa, venogono messi tutti i caratteri in minuscolo e successivamente
#il primo carattere viene messe ina maiuscolo
module ApplicationHelper

  def first_upper(name)
    name=name.downcase if name
    name=name.capitalize if name
  end

  def login_form
    render :partial => "shared/login_form"
  end
  def standard_sidebar
    render(:partial => "shared/standard_sidebar")
  end

  def user_sidebar
    if (session[:user_id])
      @link = link(User.find(session[:user_id]))
      render(:partial => "shared/user_sidebar", :object => @link)
    end
  end

  def link(user)
    amm_link = []
    teacher_link = []
    final_link = []
    didactic_office_link = []
    if (user.own_by_didactic_office?)
      didactic_office_link << {:name => "Nuovo corso", :url => url_for(:controller => "graduate_courses", :action => "new")}
    end
    if (didactic_office_link)
      final_link << {:cat => "Segreteria", :link => didactic_office_link}
    end
    amm_link << {:name => "Cambio psw", :url => url_for(:controller => "users", :action => "edit", :id => user.id)}
    if (user.manage_teachers?)
      amm_link << {:name => "Docenti", :url => url_for(:controller => "teachers", :action => "administration")}
    end
    if (user.manage_graduate_courses?)
      amm_link << {:name => "Corsi", :url => url_for(:controller => "graduate_courses", :action => "administration")}
    end
    if (user.manage_teachings?)
      amm_link << {:name => "Insegnamenti", :url => url_for(:controller => "teachings", :action => "administration")}
    end
    if (user.manage_buildings? || user.manage_classrooms?)
      amm_link << {:name => "Edifici ed aule", :url => url_for(:controller => "classrooms", :action => "administration")}
    end
    if (user.manage_timetables?)
      amm_link << {:name => "Orario", :url => url_for(:controller => "timetables", :action => "administration")}
    end

    if (amm_link)
      final_link << {:cat => "Amministrazione", :link => amm_link}
    end

    if (user.own_by_teacher?)
      teacher_link << {:name => "Vincoli", :url => url_for(:controller => "constraints", :action => "index")}
      teacher_link << {:name => "Preferenze", :url => url_for(:controller => "constraints", :action => "index")}
      teacher_link << {:name => "Dati personali", :url => url_for(:controller => "teachers", :action => "edit", :id => user.specified_id)}
    end

    if (teacher_link)
      final_link << {:cat => "Docente", :link => teacher_link}
    end
    final_link
  end
 #espressioni regolari
 #:name formato(solo nome di persona)
 Person_name=/[a-zA-Zàòèéùì]*/
 #:street formato
 Street=/[a-zA-Z0-9àòèéùì]*/
 #telephone
 Phone=/[0-9]{2,4}+[-]+[0-9]{6,8}/
 #:name (nome di un edificio)
 Building_name=/[a-zA-Z0-9àòèéùì]*/
end