class CreateTimetableEntries < ActiveRecord::Migration
  def self.up
    create_table :timetable_entries do |t|
      t.time :startTime
      t.time :endTime
      t.string :day
      t.integer :timetable_id,:null=>false
      t.integer :teaching_id,:null=>false
      t.integer :classroom_id,:null=>false
      t.timestamps
    end
    add_index(:timetable_entries,[:startTime,:endTime,:day,:classroom_id,:timetable_id], :unique => true,:name=>"indice")
   end

  def self.down
    remove_index :timetable_entries,:name=>"indice"
    drop_table :timetable_entries
  end
end
