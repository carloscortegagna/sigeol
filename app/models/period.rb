class Period < ActiveRecord::Base
  has_many :teachings
  belongs_to :timetable
end
