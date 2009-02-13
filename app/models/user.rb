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
 end
