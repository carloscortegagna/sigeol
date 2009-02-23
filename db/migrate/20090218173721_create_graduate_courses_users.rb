class CreateGraduateCoursesUsers < ActiveRecord::Migration
  def self.up
    create_table :graduate_courses_users, :id => false do |t|
      t.integer :user_id
      t.integer :graduate_course_id
    end
  end

  def self.down
    drop_table :graduate_courses_users
  end
end
