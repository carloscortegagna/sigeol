# QuiXoft - Progetto ”SIGEOL”
# NOME FILE: user.rb
# AUTORE: Grosselle Alessandro
# DATA CREAZIONE: 16/02/2009
#
# REGISTRO DELLE MODIFICHE:
#
# 24/04/2009 Approvazione del responsabile
#
# 02/04/2009 Verificato ed aggiornati i commenti in stile RDoc
#
# 14/03/2009 Aggiunto il metodo not_without_graduate_courses(graduate_course)
#
# 22/02/2009 Aggiunta dei metodi own_by_
#
# 20/02/2009 Aggiunta metodi manage_
#
# 18/02/2009 Aggiunta del metodo per l'autenticazione
#
# 18/02/2009 Aggiunta delle prime validazioni
# 
# 16/02/2009 Prima stesura


#Utente generico del sistema Sigeol. Non viene resa possibile la creazione diretta di uno _User_, ma può essere creato solo tramite un'associazione con una tipologia di utente,  come ad esempio _DidacticOffice_ o _Teacher_.

require 'digest/sha1'

class User < ActiveRecord::Base
  belongs_to :specified, :polymorphic => true, :dependent=>:destroy
  has_and_belongs_to_many :capabilities, :uniq => true
  has_and_belongs_to_many :graduate_courses, :uniq => true
  belongs_to :address, :dependent => :destroy
  before_save :encrypt_password
  before_validation :calculate_digest

  #validazioni password
  validates_presence_of :password,
                        :message=>"La password non deve essere vuota",
                        :on => :update
  validates_length_of :password,
                      :minimum=> 6,
                      :message=>"Minimo 6 caratteri",
                      :on => :update

  validates_format_of :password,
                      :with => /^[a-zA-Z0-9\.]*$/,
                      :message=>"Si accettano solo caratteri alfanumerici e il carattere punto",
                      :on => :update

  #validazioni mail
  validates_presence_of :mail,
                        :message=>"La mail non deve essere vuota"
                      
  validates_uniqueness_of :mail,
                          :message=>"La mail è già presente",
                          :on => :create

  validates_length_of :mail,
                      :maximum=> 35,
                      :message=>"La mail è troppo lunga. Max 35 caratteri",
                      :on => :update

  #la mail deve essere del tipo account@qualcosa.it oppure account@qualcosa.qualcosa.it
  validates_format_of :mail,
                     :with => /^(([a-zA-Z0-9_\.\-\+]){4,20}\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})*)?$/,
                     :message=>"La mail non è valida"

  validates_presence_of :random,
                        :message => "Non è stato scelto nessun numero casuale"

  validates_presence_of :digest,
                        :message => "Non è possibile calcolare il digest"


  validates_presence_of :specified_id,:specified_type,
                        :message=>"L'utente deve essere specificato"

  # Restituisce *true* se lo _User_ oggetto d'invocazione utente è attivo,
  # ovvero se è stata scelta per esso una password valida, altrimenti ritorna *false*.
  def active?
    attribute_present?("password")
  end

  # Forniti un indirizzo e-mail ed una password (in chiaro) restituisce l'oggetto
  # di tipo _User_ corrispondente, altrimenti restituisce il valore *nil*.
  def self.authenticate(mail, password)
    sha1 = Digest::SHA1.hexdigest(password)
    user = User.find_by_mail_and_password(mail, sha1)
    user
  end

  # Restituisce *true* se lo _User_ oggetto d'invocazione possiede i privilegi per amministrare i docenti,
  # altrimenti ritorna *false*.
  def manage_teachers?
    self.capabilities.find_by_name("Manage teachers") != nil
  end

  # Restituisce *true* se lo _User_ oggetto d'invocazione possiede i privilegi per amministrare gli insegnamenti,
  # altrimenti ritorna *false*.
  def manage_teachings?
    self.capabilities.find_by_name("Manage teachings") != nil
  end

  # Restituisce *true* se lo _User_ oggetto d'invocazione possiede i privilegi per amministrare le aule,
  # altrimenti ritorna *false*.
  def manage_classrooms?
    self.capabilities.find_by_name("Manage classrooms") != nil
  end

  # Restituisce *true* se lo _User_ oggetto d'invocazione possiede i privilegi per amministrare gli edifici,
  # altrimenti ritorna *false*.
  def manage_buildings?
    self.capabilities.find_by_name("Manage buildings") != nil
  end

  # Restituisce *true* se lo _User_ oggetto d'invocazione possiede i privilegi per amministrare gli orari,
  # altrimenti ritorna *false*.
  def manage_timetables?
    self.capabilities.find_by_name("Manage timetables") != nil
  end

  # Restituisce *true* se lo _User_ oggetto d'invocazione possiede i privilegi per amministrare i privilegi,
  # altrimenti ritorna *false*.
  def manage_capabilities?
    self.capabilities.find_by_name("Manage capabilities") != nil
  end

  # Restituisce *true* se lo _User_ oggetto d'invocazione possiede i privilegi per amministrare i corsi di laurea,
  # altrimenti ritorna *false*.
  def manage_graduate_courses?
    self.capabilities.find_by_name("Manage graduate courses") != nil
  end

  # Restituisce *true* se lo _User_ oggetto d'invocazione è detenuto da un docente (_Teacher_),
  # altrimenti ritorna *false*.
  def own_by_teacher?
    self.specified_type == "Teacher"
  end

  # Restituisce *true* se lo _User_ oggetto d'invocazione è detenuto da una segreteria didattica (_DidacticOffice_),
  # altrimenti ritorna *false*.
  def own_by_didactic_office?
    self.specified_type == "DidacticOffice"
  end

  # Viene utilizzato per sollevare un'eccezzione nel caso si tenti di cancellare l'ultimo corso di
  # laurea (parametro +graduate_course+) associato all'oggetto _User_ di invocazione.
  def before_destroy
      corsi = self.graduate_courses
      corsi.each do |c|
        if c.users.size == 1
          puts "ok"
          raise Exception
        end
      end
    end
     
  private

  # Se è presente l'attributo +password+ per lo _User_ oggetto d'invocazione, questa viene
  # crittografata utilizzato l'algoritmo SHA1 prima del salvataggio persistente nel
  # database.
  def encrypt_password #:doc:
    self.password = Digest::SHA1.hexdigest(self.password) if attribute_present?("password")
  end

  # Calcola l'attributo +digest+ necessario per l'attivazione dello _User_ oggetto di invocazione,
  # utilizzando la concatenazione tra l'indirizzo e-mail ed un numero random contenuto
  # nell'attributo +random+ e crittografando il risultato attraverso l'algoritmo SHA1. Se,
  # in caso contrario, l'attributo +digest+ è già stato calcolato, il metodo non esegue alcuna
  # operazione.
  def calculate_digest #:doc:
    ran = self.random.to_s
    self.digest = Digest::SHA1.hexdigest(self.mail+ran) unless attribute_present?("digest")
    if ENV['RAILS_ENV'] == "development"
      puts self.digest
    end
  end
end