class CreateTimetables < ActiveRecord::Migration
  def self.up
    create_table :timetables do |t|
      t.string :year
      t.integer :period_id,:null=>false
      t.integer :graduate_course_id,:null=>false
      t.timestamps
    end
    add_index(:timetables, [:period_id,:year,:graduate_course_id], :unique => true)
  end

  def self.down
    remove_index :timetables, :column=>[:period_id,:year,:graduate_course_id]
    drop_table :timetables
  end
end
