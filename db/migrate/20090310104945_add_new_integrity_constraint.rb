class AddNewIntegrityConstraint < ActiveRecord::Migration
extend MigrationHelper
  def self.up
  #vincoli sulla tabella classrooms_graduate_courses
    fk :classrooms_graduate_courses,:graduate_course_id,:graduate_courses,2
    fk :classrooms_graduate_courses,:classroom_id,:classrooms,2
 #vincoli sulla tabella graduate_courses_users
    fk :graduate_courses_users,:graduate_course_id,:graduate_courses,2
    fk :graduate_courses_users,:user_id,:users,2
  end

  def self.down
    drop_fk :classrooms_graduate_courses,:graduate_course_id
    drop_fk :classrooms_graduate_courses,:classroom_id
    drop_fk :graduate_courses_users,:graduate_course_id
    drop_fk :graduate_courses_users,:user_id
  end
end
