class Teacher < ActiveRecord::Base
    has_one :user, :as => :specified, :dependent=>:destroy
    #si associa teacher ai vincol temporali(temporal constraint)
    has_many_polymorphs :constraints, :from=>[:temporal_constraints],
      :as=> :owner, :dependent=>:destroy


  #validazioni attributo :name e :surname(si accetta l'omonimia??):
   validates_presence_of :name,:surname,
                         :message=>"Il nome non deve essere vuoto",
                         :on => :save or :create or :update
   validates_length_of :name,:surname,
                       :maximum=> 20,
                       :message=>"Il nome è troppo lungo",
                       :on => :save or :create or :update
   validates_format_of :name,:surname,
                     :with => /[a-zA-Z]/i,
                     :message=>"Si accetta solo caratteri",
                     :on => :save or :create or :update

end
