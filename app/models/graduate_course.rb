class GraduateCourse < ActiveRecord::Base
  has_many :expiry_dates
  belongs_to :academic_organization
  has_many :timetables
  has_many :curriculums
end
