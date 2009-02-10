class CreateGraduateCourses < ActiveRecord::Migration
  def self.up
    create_table :graduate_courses do |t|
      t.string :name
      t.integer :duration
      t.integer :academic_organization_id
      t.timestamps
    end
  end

  def self.down
    drop_table :graduate_courses
  end
end
