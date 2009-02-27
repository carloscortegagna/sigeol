class TemporalConstraint < ActiveRecord::Base
  #validazioni :startTime e :endTime e validazioni :day

  validates_presence_of :startHour,:endHour,:day,
                          :message=>"Alcuni campi sono vuoti"
  validates_inclusion_of :day,
                       :in => 1..5,
                       :message => "Deve essere compreso tra 1 e 5"
                     
  validate :is_correct_time?


 private

 def is_correct_time?
   if(self.startHour && self.endHour && (self.endHour<=>self.startHour)==-1)
     errors.add([:starHour,:endHour],"Attenzione l'ora di inizio è piu grande dell'ora di fine")
   end
 end

 end
