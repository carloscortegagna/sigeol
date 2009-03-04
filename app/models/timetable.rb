class Timetable < ActiveRecord::Base
  belongs_to :period
  belongs_to :graduate_course
  has_many :timetable_entries, :dependent=>:destroy

  # validazioni :year
  validates_presence_of :year,:period_id,:graduate_course_id,
                        :message => "Aggiungi l'anno accademico o il periodo o il corso di laurea"

  validates_format_of :year,
                     :with => /^[0-9]{4,4}\-[0-9]{2,2}$/,
                     :message => "deve essere scritto nella forma aaaa-aa"
                   #validazione unicità :startTime :endTime :day :classroom_id time :timetable_id
  private
  validate :unique?
  def unique?
    if Timetable.find_by_period_id_and_graduate_course_id_and_year(self.period_id,self.graduate_course_id,self.year)
      errors.add_to_base("riga già presente")
    end
  end


end

