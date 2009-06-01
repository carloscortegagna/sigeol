#=QuiXoft - Progetto ”SIGEOL”
#NOME FILE:: capability.rb
#VERSIONE:: 1.0.0
#AUTORE:: Grosselle Alessandro
#DATA CREAZIONE:: 16/02/09
#REGISTRO DELLE MODIFICHE::
# 28/04/09 Approvazione del responsabile
#
# 26/02/09 L'attributo name non può avere più di 30 caratteri
#
# 22/02/09 Piccola correzione all'espressione regolare che valida il nome
#
# 17/02/09 Aggiunta delle validazioni
#
# 16/02/09 Prima stesura
#
#Rappresentazione di un privilegio che può essere posseduto da un utente (_User_).
#Le diverse tipologie di privilegi sono:
# *Amministrazione corsi di laurea
# *Amministrazione docenti
# *Amministrazione insegnamenti
# *Amministrazione aule
# *Amministrazione edifici
# *Amministrazione tabelle orarie

class Capability < ActiveRecord::Base
 has_and_belongs_to_many :users, :uniq => true

 #validazioni :name
 validates_presence_of :name,
                       :message => "Il nome non deve essere vuoto"
 validates_length_of :name,
                     :maximum => 30,
                     :message => "Il nome è troppo lungo"
 validates_format_of :name,
                     :with => /[^a-zA-Z0-9àòèéùì\s$]*/,
                     :message =>"Si accetta solo caratteri"
 validates_uniqueness_of :name,
                         :message => "La capability è già presente"

end
