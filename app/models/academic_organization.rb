class AcademicOrganization < ActiveRecord::Base
  has_many :graduate_courses
end
