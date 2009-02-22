class TemporalConstraint < ActiveRecord::Base
  #validazioni :startTime e :endTime e validazioni :day

  validates_presence_of :startHour,:endHour,:day,
                          :message=>"Alcuni campi sono vuoti"
  validates_inclusion_of :day,
                       :in => 1..5,
                       :message => "Deve essere compreso tra 1 e 5"

 #validates_time :startHour,:endHour,
  #               :invalid_time_message=>"La data deve essere del tipo h:nn"

end
