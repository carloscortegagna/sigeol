class CreateCurriculums < ActiveRecord::Migration
  def self.up
    create_table :curriculums do |t|
      t.string :name
      t.integer :graduate_course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :curriculums
  end
end
