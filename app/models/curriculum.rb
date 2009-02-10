class Curriculum < ActiveRecord::Base
 belongs_to :graduate_course
 has_many :belongs
 has_many :teachings, :through=>:belongs
end
