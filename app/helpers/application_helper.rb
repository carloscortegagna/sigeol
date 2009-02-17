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
    name=name.downcase
    name=name.capitalize
  end
 
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