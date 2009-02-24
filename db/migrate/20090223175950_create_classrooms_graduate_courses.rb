class CreateClassroomsGraduateCourses < ActiveRecord::Migration
  def self.up
    create_table :classrooms_graduate_courses, :id => false do |t|
      t.integer :graduate_course_id, :null => false
      t.integer :classroom_id, :null => false
    end
  end

  def self.down
  end
end
