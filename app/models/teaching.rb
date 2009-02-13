class Teaching < ActiveRecord::Base
 #associazioni
 belongs_to :teacher
 belongs_to :period
 has_many :belongs
 has_many :curriculums, :through=> :belongs
 has_many :timetable_entries

#Validazioni :name
   validates_presence_of :name,
                         :message=>"Il nome non deve essere vuoto",
                         :on => :save or :create or :update
   validates_length_of :name,
                       :maximum=> 20
   validates_format_of :name,
                       :with => /[a-zA-Z0-9\.\s]/,
                       :message=>"Si accetta solo caratteri numeri e il carattere spazio",
                       :on => :save or :create or :update

  

end
