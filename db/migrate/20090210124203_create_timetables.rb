class CreateTimetables < ActiveRecord::Migration
  def self.up
    create_table :timetables do |t|
      t.string :year
      t.integer :period_id
      t.integer :graduate_course_id
      t.timestamps
    end
  end

  def self.down
    drop_table :timetables
  end
end
