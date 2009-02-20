class CreateTimetableEntries < ActiveRecord::Migration
  def self.up
    create_table :timetable_entries do |t|
      t.time :startTime
      t.time :endTime
      t.string :day
      t.integer :timetable_id
      t.integer :teaching_id
      t.integer :classroom_id
      t.timestamps
    end
  end

  def self.down
    drop_table :timetable_entries
  end
end
