class CreateGraduateCourses < ActiveRecord::Migration
  def self.up
    create_table :graduate_courses do |t|
      t.string :name
      t.integer :duration
      t.integer :academic_organization_id,:null=>false
      t.timestamps
    end
    add_index(:graduate_courses, :name, :unique => true)
  end

  def self.down
    remove_index :graduate_courses, :column=>:name
    drop_table :graduate_courses
  end
end
