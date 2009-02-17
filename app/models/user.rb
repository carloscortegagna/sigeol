#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: user.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#13/02/09 Aggiunta del metodo per l'autenticazione
#13/02/09 Aggiunta delle prime validazioni
#12/02/09 Prima stesura

require 'digest/sha1'

class User < ActiveRecord::Base
  belongs_to :specified, :polymorphic => true, :dependent=>:destroy
   has_and_belongs_to_many :capabilities
   belongs_to :address

  before_save :encrypt_password
  before_validation :calculate_digest

  #validazioni password
    validates_presence_of :password,
                         :message=>"La password non deve essere vuota",
                         :on => :update
   validates_length_of :password,
                       :in=> 6..20,
                       :message=>"La password troppo corta. Min 6, Max 20",
                       :on => :update

 validates_format_of :password,
                     :with => /[a-zA-Z0-9\.]/,
                     :message=>"Si accetta solo caratteri numeri e il carattere .",
                     :on => :update

  #validazioni mail
  validates_presence_of :mail,
                        :message=>"La mail non deve essere vuota",
                        :on => :create
  validates_uniqueness_of :mail,
                          :message=>"La mail è già presente",
                          :on => :create

  #la mail deve essere del tipo account@qualcosa.qualcosa.it oppure account@qualcosa.qualcosa.it
  validates_format_of :mail,
                     :with => /([^@ t]{8,12})+@+(([^@ t]{1,12})+\.+[a-z]{2,3})|(([^@ t]{1,12})+\.+([^@ t]{1,12})+\.+[a-z]{2,3})/,
                     :message=>"La mail non è valida"
  #l'utente deve essere specificato
  validates_presence_of :specified_type,
                        :message=>"Utente non specificato"
                      
  validates_presence_of :random,
                        :message => "Non è stato scelto nessun numero casuale"

  validates_presence_of :digest,
                        :message => "Non è possibile calcolare il digest"

  def active?
    attribute_present?("password")
  end
  def self.authenticate(mail, password)
    sha1 = Digest::SHA1.hexdigest(password)
    user = User.find_by_mail_and_password(mail, sha1)
    user
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
 end
