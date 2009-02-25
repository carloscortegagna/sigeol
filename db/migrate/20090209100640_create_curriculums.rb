class CreateCurriculums < ActiveRecord::Migration
  def self.up
    create_table :curriculums do |t|
      t.string :name
      t.integer :graduate_course_id,:null=>false
      t.timestamps
    end
    add_index(:curriculums,[:name,:graduate_course_id], :unique => true)
  end

  def self.down
    remove_index :curriculums, [:name,:graduate_course_id]
    drop_table :curriculums
  end
end
