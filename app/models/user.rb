#QuiXoft - Progetto ”SIGEOL”
#NOME FILE: user.rb
#VERSIONE: 0.3
#AUTORE: Grosselle Alessandro
#DATA CREAZIONE: 12/02/09
#REGISTRO DELLE MODIFICHE:
#13/02/09 Agginta del metodo per l'autenticazione
#13/02/09 Aggiunta delle validazione
#12/02/09 Prima stesura

require 'digest/sha1'

class User < ActiveRecord::Base
   belongs_to :specified, :polymorphic => true
   has_and_belongs_to_many :capabilities
   belongs_to :address
    #validazioni attr. password
    validates_presence_of :password,
                         :message=>"password must exist",
                         :on => :save or :create or :update
   validates_length_of :password,
                       :in=> 6..20,
                       :message=>"password too short. min 6 characters",
                       :on => :save or :create or :update

 validates_presence_of :mail,
                         :message=>"mail must exist",
                         :on => :save or :create or :update
   #validazioni attr. mail
  #più account non possono avere la stessa mail
  validates_uniqueness_of :mail,
                          :message=>"mail already exist",
                          :on => :save or :create or :update
  #la mail deve essere del tipo account@qualcosa.qualcosa
  validates_format_of :mail,
                     :with => /([^@ t]{8,12})+@+([^@ t])+\.+[a-z]{2,3}/,
                     :message=>"mail is invalid",
                     :on => :save or :create or :update

  #l'utente deve essere specificato
  validates_presence_of :specified

  def self.authenticate(mail, password)
    sha1 = Digest::SHA1.hexdigest(password)
    user = User.find_by_mail_and_password(mail, sha1)
  end
 end
