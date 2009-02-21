class Timetable < ActiveRecord::Base
  belongs_to :period
  belongs_to :graduate_course
  has_many :timetable_entries, :dependent=>:destroy

  # validazioni :year
  validates_presence_of :year,
                        :message=>"Aggiungi l'anno accademico"

  validates_format_of :year,
                     :with => /^[0-9]{4,4}+-+[0-9]{2,2}$/,
                     :message=>"deve essere scritto nella forma aaaa-aa",
                     :on => :update

  validates_uniqueness_of :year,
                          :message=>"Anno accademico già presente",
                          :on => :create

end

