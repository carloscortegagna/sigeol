class GraduateCourse < ActiveRecord::Base
  has_many :expiry_dates
  belongs_to :academic_organization
  has_many :timetables
  has_many :curriculums
  has_many_polymorphs :constraints, :from => [:quantity_constraints,:boolean_constraints, :temporal_constraints],
    :as=> :owner

end
