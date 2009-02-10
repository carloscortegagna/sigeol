class Timetable < ActiveRecord::Base
  belongs_to :period
  belongs_to :graduate_course
  has_many :timetable_entries
end
