class Teaching < ActiveRecord::Base
 belongs_to :teacher
 belongs_to :period
 has_many :belongs
 has_many :curriculums, :through=> :belongs
 has_many :timetable_entries
end
