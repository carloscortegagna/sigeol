class CreateClassroomsGraduateCourses < ActiveRecord::Migration
  def self.up
    create_table :classrooms_graduate_courses, :id => false do |t|
      t.integer :graduate_course_id, :null => false
      t.integer :classroom_id, :null => false
    end
    add_index(:classrooms_graduate_courses, [:graduate_course_id,:classroom_id], :name=>"index_join", :unique => true)
  end

  def self.down
    remove_index(:classrooms_graduate_courses, :name=>"index_join")
    drop_table :classrooms_graduate_courses
  end
end
