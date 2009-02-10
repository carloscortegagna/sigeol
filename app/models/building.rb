class Building < ActiveRecord::Base
 belongs_to :address
 has_many :classrooms
end
