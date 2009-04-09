#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: user.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 16/02/09
#REGISTRO DELLE MODIFICHE:
#14/03/09 Aggiunto il metodo not_without_graduate_courses(graduate_course)
#22/02/09 Aggiunta dei metodi own_by_
#20/02/09 Aggiunta metodi manage_
#18/02/09 Aggiunta del metodo per l'autenticazione
#18/02/09 Aggiunta delle prime validazioni
#16/02/09 Prima stesura

require 'digest/sha1'

class User < ActiveRecord::Base
  belongs_to :specified, :polymorphic => true, :dependent=>:destroy
  has_and_belongs_to_many :capabilities, :uniq => true
  has_and_belongs_to_many :graduate_courses, :uniq => true, :before_remove => :not_without_graduate_courses
  belongs_to :address, :dependent => :destroy
  before_save :encrypt_password
  before_validation :calculate_digest

  #validazioni password
    validates_presence_of :password,
                         :message=>"La password non deve essere vuota",
                         :on => :update
   validates_length_of :password,
                       :minimum=> 6,
                       :message=>"La password troppo corta. Min 6 caratteri",
                       :on => :update

 validates_format_of :password,
                     :with => /^[a-zA-Z0-9\.]*$/,
                     :message=>"Si accetta solo caratteri numeri e il carattere .",
                     :on => :update

  #validazioni mail
  validates_presence_of :mail,
                        :message=>"La mail non deve essere vuota"
                      
  validates_uniqueness_of :mail,
                          :message=>"La mail è già presente",
                          :on => :create

  #la mail deve essere del tipo account@qualcosa.qualcosa.it oppure account@qualcosa.qualcosa.it
  validates_format_of :mail,
                     :with => /^([a-zA-Z0-9_\.\-\+]){4,20}\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})$/,
                     :message=>"La mail non è valida"

  validates_presence_of :random,
                        :message => "Non è stato scelto nessun numero casuale"

  validates_presence_of :digest,
                        :message => "Non è possibile calcolare il digest"


  validates_presence_of :specified_id,:specified_type,
                        :message=>"L'utente deve essere specificato"
  
  validate 
  def active?
    attribute_present?("password")
  end
  def self.authenticate(mail, password)
    sha1 = Digest::SHA1.hexdigest(password)
    user = User.find_by_mail_and_password(mail, sha1)
    user
  end

  def manage_teachers?
    self.capabilities.find_by_name("Manage teachers") != nil
  end
  def manage_teachings?
    self.capabilities.find_by_name("Manage teachings") != nil
  end
  def manage_classrooms?
    self.capabilities.find_by_name("Manage classrooms") != nil
  end
  def manage_buildings?
    self.capabilities.find_by_name("Manage buildings") != nil
  end
  def manage_timetables?
    self.capabilities.find_by_name("Manage timetables") != nil
  end
  def manage_capabilities?
    self.capabilities.find_by_name("Manage capabilities") != nil
  end
    def manage_graduate_courses?
    self.capabilities.find_by_name("Manage graduate courses") != nil
  end
  def own_by_teacher?
    self.specified_type == "Teacher"
  end
  def own_by_didactic_office?
    self.specified_type == "DidacticOffice"
  end

  private

  def encrypt_password
    self.password = Digest::SHA1.hexdigest(self.password) if attribute_present?("password")
  end

  def calculate_digest
    ran = self.random.to_s
    self.digest = Digest::SHA1.hexdigest(self.mail+ran) unless attribute_present?("digest")
    if ENV['RAILS_ENV'] == "development"
      puts self.digest
    end
  end

  def not_without_graduate_courses(graduate_course)
    if self.graduate_courses.size == 1
      raise Exception
    end
  end
 end
